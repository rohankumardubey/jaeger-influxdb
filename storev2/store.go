package storev2

import (
	"context"
	"io"

	"github.com/influxdata/influxdb"
	"github.com/influxdata/jaeger-store/common"
	"github.com/influxdata/jaeger-store/config"
	"github.com/influxdata/jaeger-store/influx2http"
	"github.com/jaegertracing/jaeger/plugin/storage/grpc/shared"
	"github.com/jaegertracing/jaeger/storage/dependencystore"
	"github.com/jaegertracing/jaeger/storage/spanstore"
	"go.uber.org/zap"
)

var (
	_ shared.StoragePlugin = (*Store)(nil)
	_ io.Closer            = (*Store)(nil)
)

type Store struct {
	reader *Reader
	writer *Writer
}

func NewStore(conf *config.Configuration, logger *zap.Logger) (*Store, error) {
	orgID, err := findOrgID(context.TODO(), conf.Host, conf.Token, conf.Organization)
	if err != nil {
		return nil, err
	}

	bucketID, err := findBucketID(context.TODO(), conf.Host, conf.Token, orgID, conf.Bucket)
	if err != nil {
		return nil, err
	}

	fluxService := &influx2http.FluxService{
		Addr:  conf.Host,
		Token: conf.Token,
	}
	reader := NewReader(fluxService, orgID, conf.Bucket, common.DefaultSpanMeasurement, common.DefaultLogMeasurement, conf.DefaultLookback, logger)

	writeService := &influx2http.WriteService{
		Addr:      conf.Host,
		Token:     conf.Token,
		Precision: "ns",
	}
	writer := NewWriter(writeService, orgID, bucketID, common.DefaultSpanMeasurement, common.DefaultLogMeasurement, logger)

	return &Store{
		reader: reader,
		writer: writer,
	}, nil
}

func (s *Store) Close() error {
	return s.writer.Close()
}

func (s *Store) SpanReader() spanstore.Reader {
	return s.reader
}

func (s *Store) SpanWriter() spanstore.Writer {
	return s.writer
}

func (s *Store) DependencyReader() dependencystore.Reader {
	return s.reader
}

func findOrgID(ctx context.Context, host, token, org string) (influxdb.ID, error) {
	svc := &influx2http.OrganizationService{
		Addr:  host,
		Token: token,
	}

	o, err := svc.FindOrganization(ctx, influxdb.OrganizationFilter{
		Name: &org,
	})
	if err != nil {
		return influxdb.InvalidID(), err
	}

	return o.ID, nil
}

func findBucketID(ctx context.Context, host, token string, orgID influxdb.ID, bucket string) (influxdb.ID, error) {
	svc := &influx2http.BucketService{
		Addr:  host,
		Token: token,
	}

	b, err := svc.FindBucket(ctx, influxdb.BucketFilter{
		Name:           &bucket,
		OrganizationID: &orgID,
	})
	if err != nil {
		return influxdb.InvalidID(), err
	}

	return b.ID, nil
}