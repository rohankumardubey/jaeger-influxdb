/*
    cron is a fast, zero-allocation cron parsing library.  We aim to be Quartz cron compatible eventually.
    Currently we support:
    - standard five-position cron
    - six-position cron with seconds
    - seven-position cron with seconds and years
    - case-insensitive names of the days of the week
    - case-insensitive month names
*/

package cron

import (
    "fmt"
     "errors"
    "math/bits"
    "time"
)

// the following comment is there so it will end up, in the generated code.
// the blank line below this needs to be here.

// Code generated by ragel DO NOT EDIT.

//lint:file-ignore SA4006 Ignore unused, its generated
//lint:file-ignore U1000 Ignore all unused code, its generated


%% machine parse;
%% variable data s;
%% write data;


var skips = [...]uint64{
                    ^uint64(0),
                    1|1<<2|1<<4|1<<6|1<<8|1<<10|1<<12|1<<14|1<<16|1<<18|1<<20|1<<22|1<<24|1<<26|1<<28|1<<30|1<<32|1<<34|1<<36|1<<38|1<<40|1<<42|1<<44|1<<46|1<<48|1<<50|1<<52|1<<54|1<<56|1<<58|1<<60|1<<62,
                    1|1<<3|1<<6|1<<9|1<<12|1<<15|1<<18|1<<21|1<<24|1<<27|1<<30|1<<33|1<<36|1<<39|1<<42|1<<45|1<<48|1<<51|1<<54|1<<57|1<<60|1<<63,
                    1|1<<4|1<<8|1<<12|1<<16|1<<20|1<<24|1<<28|1<<32|1<<36|1<<40|1<<44|1<<48|1<<52|1<<56|1<<60,
                    1|1<<5|1<<10|1<<15|1<<20|1<<25|1<<30|1<<35|1<<40|1<<45|1<<50|1<<55|1<<60,
                    1|1<<6|1<<12|1<<18|1<<24|1<<30|1<<36|1<<42|1<<48|1<<54|1<<60,
                    1|1<<7|1<<14|1<<21|1<<28|1<<35|1<<42|1<<49|1<<56|1<<63,
                    1|1<<8|1<<16|1<<24|1<<32|1<<40|1<<48|1<<56,
                    1|1<<9|1<<18|1<<27|1<<36|1<<45|1<<54|1<<63,
                    1|1<<10|1<<20|1<<30|1<<40|1<<50|1<<60,
                    1|1<<11|1<<22|1<<33|1<<44|1<<55,
                    1|1<<12|1<<24|1<<36|1<<48,
                    1|1<<13|1<<26|1<<39|1<<52,
                    1|1<<14|1<<28|1<<42|1<<56,
                    1|1<<15|1<<30|1<<45,
                    1|1<<16|1<<32|1<<48,
                    1|1<<17|1<<34|1<<51,
                    1|1<<18|1<<36|1<<54,
                    1|1<<19|1<<38|1<<57,
                    1|1<<20|1<<40,
                    1|1<<21|1<<42,
                    1|1<<22|1<<44,
                    1|1<<23|1<<46,
                    1|1<<24|1<<48,
                    1|1<<25|1<<50,
                    1|1<<26|1<<52,
                    1|1<<27|1<<54,
                    1|1<<28|1<<56,
                    1|1<<29|1<<58,
                    1|1<<30|1<<59,
                    1|1<<31|1<<61,
                    1|1<<32|1<<63,
                    1|1<<33,
                    1|1<<34,
                    1|1<<35,
                    1|1<<36,
                    1|1<<37,
                    1|1<<38,
                    1|1<<39,
                    1|1<<40,
                    1|1<<41,
                    1|1<<42,
                    1|1<<43,
                    1|1<<44,
                    1|1<<45,
                    1|1<<46,
                    1|1<<47,
                    1|1<<48,
                    1|1<<49,
                    1|1<<50,
                    1|1<<51,
                    1|1<<52,
                    1|1<<53,
                    1|1<<54,
                    1|1<<55,
                    1|1<<56,
                    1|1<<57,
                    1|1<<58,
                    1|1<<59,
                    1|1<<60,
                    1|1<<61,
                    1|1<<62,
                    1|1<<63,
                }

const (
    mask60 = (^uint64(0))>>(64-60)
    mask31 = (^uint64(0))>>(64-31)
    mask7  = (^uint64(0))>>(64-7)
    mask24 = (^uint64(0))>>(64-24)
    mask12 = (^uint64(0))>>(64-12)
)

func parse(s string)(Parsed, error){
    nt:=Parsed{}
    cs, p, pe, eof:= 0, 0,len(s), len(s)
    
    // init scanner vars
    act, ts, te := 0, 0, 0
    _, _, _ = act, ts, te // we have to do this.

    // for fcall
    top := 0
    _ = top
    stack := [8]int{}
    mark, backtrack := 0,0
    _ = mark
    _ = backtrack
    m, d,  start, end, dec, befDec, sign:=uint64(0), uint64(0), uint64(0), uint64(0), int64(0), int64(0), int64(0)
    _ = d
    var dur time.Duration
    _, _, _, _ = dec, sign, dur, befDec

    // TODO(docmerlin): handle ranges
    %% write init;
    //m,h := 1<<0,1<<0
    %%{
        action mark {
            mark = p;
        }

        action appendSeconds {
            {
                if d>=60 {
                    return nt, fmt.Errorf("invalid second */%d", d)
                }
                if start>=60 {
                    return nt, fmt.Errorf("invalid start second %d", start)
                }
                if end>=60 {
                    return nt, fmt.Errorf("invalid end second %d", end)
                }
                // handle the case that isn't a 
                endOp := 64-end-1
                if end==0{
                    endOp = 0
                }
                endMask := (^uint64(0))<<endOp>>endOp
                if d==0{
                    nt.second |= 1<<m
                }else{
                    nt.second |= ((skips[d-1]&mask60)<<start)&endMask
                }
            }
        }

        action appendMinutes {
            {
                if d>=60 {
                    return nt, fmt.Errorf("invalid minute */%d", d)
                }
                if start>=60 {
                    return nt, fmt.Errorf("invalid start minute %d", start)
                }
                if end>=60 {
                    return nt, fmt.Errorf("invalid end minute %d", start)
                }
                // handle the case that isn't a 
                endOp := 64-end-1
                if end==0{
                    endOp = 0
                }
                endMask := (^uint64(0))<<endOp>>endOp
                if d==0{
                    nt.minute |= 1<<m
                }else{
                    nt.minute |= ((skips[d-1]&mask60)<<start)&endMask
                }
            }
        }

        action appendHours {
            {
                if d>=24{
                    return nt, fmt.Errorf("invalid hour */%d", d)
                }
                if start>=24 {
                    return nt, fmt.Errorf("invalid start hour %d", start)
                }
                if end>=24 {
                    return nt, fmt.Errorf("invalid end hour %d", start)
                }
                // handle the case that isn't a 
                endOp := 64-end-1
                if end==0{
                    endOp = 0
                }
                endMask := (^uint64(0))<<endOp>>endOp
                if d==0{
                    nt.hour |= 1<<m
                }else{
                    nt.hour |= uint32(((skips[d-1]&mask24)<<start)&endMask)
                }
            }
        }

        action appendMonths {
            {
                if d>12{
                    return nt, fmt.Errorf("invalid month */%d", d)
                }
                if start>12 {
                    return nt, fmt.Errorf("invalid start month %d", start)
                }
                if  end>12 {
                    return nt, fmt.Errorf("invalid end month %d", start)
                }
                // handle the case that isn't an error
                endOp := 16-end
                if end==0{
                    endOp = 0
                }
                endMask := (^uint16(0))<<endOp>>endOp
                if d==0{
                    nt.month |= 1<<(start-1)
                }else{
                    nt.month |= (uint16(skips[d-1]&mask12)<<uint16(start-1))&endMask
                }
            }
        }

        action appendStarSlDoW {
            {
                //const sundaysAtFirst = uint64(1 | 1<<7 | 1<<14 | 1<<21 | 1<<28 | 1<<35 | 1<<42)
                if d>7{
                    return nt, fmt.Errorf("invalid day of week */%d", d)
                }
                if start>7 {
                    return nt, fmt.Errorf("invalid start day of week %d", start)
                }
                if end==7{
                    end=6 // for compatibility with older crons
                }
                if end>6 {
                    return nt, fmt.Errorf("invalid end day of week %d", start)
                }
                if start>end {
                    return nt, errors.New("invalid day of week range start must be before end")
                }

                // handle the case that isn't a 
                dayRange := (^uint64(0))<<(64 - (end-start+1))>>(64 - end-1)
                if d==0{
                    //nt.dow |= uint32(sundaysAtFirst<<start)
                    nt.dow |= uint8(1<<start)
                }else{
                    dayRange&=skips[d-1]&mask7
                    nt.dow |= uint8(dayRange)
                }
            }
        }
        # this isn't optimized, because I really doubt people will use it very often.  If someone wants to optimize it, go ahead
        action appendYears {
            // short circuit for the most common cases.
            if d>128 {
                return nt, fmt.Errorf("invalid year */%d", d)
            }
            if start<1970 || start>2099 {
                return nt, fmt.Errorf("invalid start year %d", start)
            }
            if end<1970 || end>2099 {
                return nt, fmt.Errorf("invalid end year %d", end)
            }
            if d==0{
                nt.setYear(int(start))
            }else if d==1&&start==end{
                nt.low=^uint64(0)
                nt.high=^uint64(0)
                nt.end=^uint8(0)
            }else if d >=64 {
                for i:=start;i<=end;i+=d{
                        nt.setYear(int(i))
                }
            } else {
                s := start - 1970
                e := end - 1970
                repeat:=d-1
                sk := skips[repeat]
                switch{
                case end<=start:
                    nt.setYear(int(start))
                case s < 64:
                    switch{
                    case e < 64:
                    nt.low |= sk<<s & ((^uint64(0)) >> (63-e))
                    case e < 128:
                    nt.low |= sk<<s
                    nt.high |= (sk << (repeat - uint64(bits.LeadingZeros64(nt.low)))) & ((^uint64(0)) >> ( 127 - e ))
                    default:
                    nt.low |= sk<<s
                    nt.high |= (sk << (repeat - uint64(bits.LeadingZeros64(nt.low))))
                    nt.end |= uint8((sk << (repeat - uint64(bits.LeadingZeros64(nt.high)))) & ((^uint64(0)) >> ( 191 - e )))
                    }
                case s < 128:
                    switch{
                    case e < 128:
                        nt.high |= sk<<( s - 64 ) & ((^uint64(0)) >> ( 127 - e ))
                    default:
                        nt.high |= sk<<( s - 64)
                        nt.end |= uint8((sk << (repeat - uint64(bits.LeadingZeros64(nt.high)))) & ((^uint64(0)) >> ( 191 - e )))
                    }
                case s < 192:
                    nt.end |= uint8(sk<<( s - 128 ) & ((^uint64(0)) >> ( 191 - e )))
                }
            }
        }

        action appendDoM {
            {
                if d>=31{
                    return nt, fmt.Errorf("invalid day month */%d", d)
                }
                if start>30 {
                    return nt, fmt.Errorf("invalid start month %d", start)
                }
                if end>31 {
                    return nt, fmt.Errorf("invalid end month %d", start)
                }
                // handle the case that isn't a 
                endOp := 64-end-1
                if end==0{
                    endOp = 0
                }
                endMask := (^uint64(0))<<endOp>>endOp
                if d==0{
                    nt.dom |= 1<<(m-1)
                }else{
                    nt.dom |= uint32(((skips[d-1]&mask31)<<start)&endMask)
                }
            }
        }

        action len_err {
            return nt, fmt.Errorf("too many positions in cron")
        }

        action parse_err {
            fhold;
            return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])
        }

        digits = (digit+) >mark %{
            m=0
            for _, x := range s[mark:p] {
                m*=10
                m+=uint64(x-'0') // since we know that x is a numerical digit we can subtract the rune '0' to convert to a number from 0 to 9
            }
        };

        allowedNonSpace = alnum|"/"|"*"|","|"-";
        slash = "/";
        comma = ",";
        hypen = "-";

        dowName = ( /SUN/i @{m=0} | /MON/i @{m=1} | /TUE/i @{m=2} | /WED/i @{m=3} | /THU/i @{m=4} | /FRI/i @{m=5} | /SAT/i @{m=6} );
        monthName = ( /JAN/i @{m=1} | /FEB/i @{m=2} | /MAR/i @{m=3} | /APR/i @{m=4} | /MAY/i @{m=5} | /JUN/i @{m=6} | /JUL/i @{m=7} | /AUG/i @{m=8} | /SEP/i @{m=9} | /OCT/i @{m=10} | /NOV/i @{m=11} | /DEC/i @{m=12} ) ;
        digitlist = digits ("," space* digits)*;
        starSlashDigits = ( ("*" @{m=1})( slash %mark digits )? );
        digitsAndSlashList = ( starSlashDigits | digits ) ( ',' ( starSlashDigits | digits ) )*;

        secminrange = ( ( "*" %{ start=0;end=59;m=1;d=1; } ) |  (digits %{ start=m; end=0;d=0;} ( "-" digits %{ end=m; d=1;} )? )) >{d=0;};
        second =  ( secminrange ("/" digits %{d=m})? ) %appendSeconds; 
        seconds = second ("," second) *;

        minute = ( secminrange ("/" digits %{d=m})? ) %appendMinutes; 
        minutes = minute ("," minute) *;

        hourrange = ( ( "*" %{ start=0;end=23;m=1;d=1; } ) |  (digits %{ start=m; end=0;d=0;} ( "-" digits %{ end=m; d=1;} )? )) >{d=0;};
        hour = ( hourrange ("/" digits %{d=m})? ) %appendHours; 
        hours = hour ("," hour) *;

        domrange = ( ( "*" %{ start=0;end=30;m=0;d=1; } ) |  (( digits | dowName ) %{ start=m-1; end=0;d=0;} ( "-" ( digits | dowName ) %{ end=m-1; d=1;} )? )) >{d=0;};
        dom = ( domrange ("/" digits %{d=m})? ) %appendDoM;
        doms = dom ("," dom) *;

        monthrange = ( ( "*" %{ start=1;end=12;m=0;d=1; } ) |  (( digits | monthName ) %{ start=m; end=0;d=0;} ( "-" ( digits | monthName ) %{ end=m; d=1;} )? )) >{d=0;};
        month = ( monthrange ("/" digits %{d=m})? ) %appendMonths; 
        months = month ("," month) *;

        dowrange = ( ( "*" %{ start=0;end=6;m=0;d=1; } ) |  (( digits | dowName ) %{ start=m; end=6;d=0;} ( "-" ( digits | dowName ) %{ end=m; d=1;} )? )) >{d=0;};
        dow = ( dowrange ("/" digits %{d=m})? ) %appendStarSlDoW;
        dows = dow ("," dow) *;

        yearrange = ( ( "*" %{ start=1970;end=2099;m=0;d=1; } ) |  (( digits ) %{ start=m; end=m; d=0;} ( "-" ( digits ) %{ end=m; d=1;} )? )) >{d=0;};
        year = ( yearrange ("/" digits %{d=m})? ) %appendYears; 
        years = year ("," year) *;
        sixPos:= (seconds space+ minutes space+ hours space+ doms space+ months space+ dows) space*; 
        sevenPos:= (seconds space+ minutes space+ hours space+ doms space+ months space+ dows space+ years) space*;
        fivePos := (minutes space+ hours space+ doms space+ months space+ dows) space*;
        durationMacro := |* 
                    digits . (
                    (/y/i %{ nt.setEveryYear(int(m));})
                    | (/ms/i %{ nt.addEveryDur(time.Duration(m)*time.Millisecond); })
                    | (/mo/i %{ nt.setEveryMonth(int(m)); })
                    | ((/[??u]/i./s/i?) %{ nt.addEveryDur(time.Duration(m)*time.Microsecond); })
                    | (/ns/i %{ nt.addEveryDur( time.Duration(m)) ;})
                    | (/s/i %{nt.addEveryDur(time.Duration(m)*time.Second); })
                    | ((/h/i./r/i?) %{ nt.addEveryDur(time.Duration(m)*time.Hour); })
                    | (/m/i %{ nt.addEveryDur(time.Duration(m)*time.Minute); })
                    | (/d/i %{ nt.setEveryDay(int(m)); })
                ) => {};
            space+ => {};
            [0-9]| ^("y"|"m"|"??"|"u"|"n"|"h"|"m"|"d") => parse_err;
        *|;
        atMacro := |*
            ("yearly"|"annually") space* => {
                nt.second=1
                nt.minute=1
                nt.hour=1
                nt.dom=1
                nt.month=1
                nt.dow=^uint8(0)
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end=^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            "monthly" space* => {
                nt.second=1
                nt.minute=1
                nt.hour=1
                nt.dom=1
                nt.month=((1<<13) - 1) // every month
                nt.dow=^uint8(0)
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end =^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            "weekly" space* => {
                nt.second=1
                nt.minute=1
                nt.hour=1
                nt.dom=^uint32(0)
                nt.month=((1<<13) - 1) // every month
                nt.dow=1
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end =^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            ("daily"|"midnight") space* => {
                nt.second=1
                nt.minute=1
                nt.hour=1
                nt.dom=^uint32(0)
                nt.month=((1<<13) - 1) // every month
                nt.dow=^uint8(0)
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end =^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            "hourly" space* => {
                nt.second=1
                nt.minute=1
                nt.hour=^uint32(0)
                nt.dom=^uint32(0)
                nt.month=((1<<13) - 1) // every month
                nt.dow=^uint8(0)
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end =^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            "every_minute" space* => {
                nt.second=1
                nt.minute=(1<<60)-1
                nt.hour=^uint32(0)
                nt.dom=^uint32(0)
                nt.month=((1<<13) - 1) // every month
                nt.dow=^uint8(0)
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end =^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            "every_second" space* => {
                nt.second=(1<<60)-1
                nt.minute=(1<<60)-1
                nt.hour=^uint32(0)
                nt.dom=^uint32(0)
                nt.month=((1<<13) - 1) // every month
                nt.dow=^uint8(0)
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                nt.end =^uint8(0)
                if p!=pe-1{return nt, fmt.Errorf("error in parsing at char %d, '%s'", p, s[p:p+1])}
            };
            # this parser can also parse golang duration format
            "every" space+ >mark=> {
                nt.every = true;
                p = mark
                fcall durationMacro;
            };
            /.+/ => parse_err;
        *|; 
        main := |*
            space* => mark; # to get rid of extra leading white space
            # 5 position cron
            ((allowedNonSpace+ space+){4} allowedNonSpace+) >mark => {
                _ = p // this is to make staticcheck happy
                // set seconds to 0 second of minute
                nt.second=1
                // set year to be permissive
                nt.high=^uint64(0)
                nt.low=^uint64(0)
                fexec mark;
                fcall fivePos;
                }; # 6 position cron with seconds but no year
            ((allowedNonSpace+ space+){5} allowedNonSpace+) >mark => {
                _ = p // this is to make staticcheck happy
                nt.high=^uint64(0) // set year to be permissive
                nt.low=^uint64(0)
                fexec mark;
                fgoto sixPos;
                }; # 7 position cron
            ((allowedNonSpace+ space+){6} allowedNonSpace+) >mark => {
                _ = p // this is to make staticcheck happy
                fexec mark;
                fcall sevenPos;
                };
            "@" => {fcall atMacro;};
             ((allowedNonSpace+ space+){7} (allowedNonSpace+ space?)+) => parse_err;
             /.+/ => parse_err;

        *|;
    }%%

    %% write exec;
    if !nt.valid() {
        return nt, fmt.Errorf("failed to parse cron string '%s' %v %b", s, nt, mask12)
    }
    return nt,  nil
}


