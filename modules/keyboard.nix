{ ... }: { services.kanata = {
  enable = true;
  keyboards.dmote.devices = [
    "/dev/input/by-id/usb-Me_Dactyl_Manuform:_OTE_0.1.0-event-kbd"
  ];
  keyboards.dmote.config = ''
    (defvar
      tap-timeout   100
      hold-timeout  200
      tt $tap-timeout
      ht $hold-timeout
    )
    (defalias
      t_r (chord taipo r)
      t_s (chord taipo s)
      t_n (chord taipo n)
      t_i (chord taipo i)
      t_a (chord taipo a)
      t_o (chord taipo o)
      t_t (chord taipo t)
      t_e (chord taipo e)
      t_in (chord taipo in)
      t_out (chord taipo out)
    )
    (defsrc
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rmet rctl
      f12
    )
    (deflayer qwerty
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rmet rctl
      (layer-switch taipo)
    )
    (deflayer taipo
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX  XX
      XX   @t_r @t_s @t_n @t_i XX   XX   @t_i @t_n @t_s @t_r XX   @t_in
      XX   @t_a @t_o @t_t @t_e XX   XX   @t_e @t_t @t_o @t_a XX
      XX   XX @t_out          @t_in           @t_out XX XX
      (layer-switch qwerty)
    )
    (defchords taipo 500
      ;; (r s n i a o t e in out)
      (r                     ) r
      (r               in    ) S-r
      (r                  out) S-.
      (  s                   ) s
      (  s             in    ) S-s
      (  s                out) S-]
      (    n                 ) n
      (    n           in    ) S-n
      (    n              out) ]
      (      i               ) i
      (      i         in    ) S-i
      (      i            out) S-9
      (        a             ) a
      (        a       in    ) S-a
      (        a          out) S-,
      (          o           ) o
      (          o     in    ) S-o
      (          o        out) S-[
      (            t         ) t
      (            t   in    ) S-t
      (            t      out) [
      (              e       ) e
      (              e in    ) S-e
      (              e    out) S-0
      (r s                   ) b
      (r s             in    ) S-b
      (r s                out) 9
      (    n i               ) y
      (    n i         in    ) S-y
      (    n i            out) 5
      (        a o           ) l
      (        a o     in    ) S-l
      (        a o        out) 4
      (            t e       ) h
      (            t e in    ) S-h
      (            t e    out) 0
      (r   n                 ) z
      (r   n           in    ) S-z
      (r   n              out) 8
      (  s   i               ) f
      (  s   i         in    ) S-f
      (  s   i            out) 6
      (        a   t         ) q
      (        a   t   in    ) S-q
      (        a   t      out) 3
      (          o   e       ) c
      (          o   e in    ) S-c
      (          o   e    out) 1
      (r     i               ) g
      (r     i         in    ) S-g
      (r     i            out) S-3
      (  s n                 ) p
      (  s n           in    ) S-p
      (  s n              out) 7
      (        a     e       ) d
      (        a     e in    ) S-d
      (        a     e    out) S-2
      (          o t         ) u
      (          o t   in    ) S-u
      (          o t      out) 2
      (r           t         ) x
      (r           t   in    ) S-x
      (r           t      out) S-6
      (  s           e       ) v
      (  s           e in    ) S-v
      (  s           e    out) S-8
      (    n   a             ) j
      (    n   a       in    ) S-j
      (    n   a          out) =
      (      i   o           ) k
      (      i   o     in    ) S-k
      (      i   o        out) S-+
      (r             e       ) m
      (r             e in    ) S-m
      (r             e    out) S-4
      (  s         t         ) /
      (  s         t   in    ) \
      (  s         t      out) S-\
      (    n     o           ) -
      (    n     o     in    ) _
      (    n     o        out) S-5
      (      i a             ) w
      (      i a       in    ) S-w
      (      i a          out) S-7
      (r         o           ) ;
      (r         o     in    ) S-;
   ;; (r         o        out) XX
      (  s     a             ) '
      (  s     a       in    ) S-'
      (  s     a          out) grv
      (    n         e       ) ,
      (    n         e in    ) .
      (    n         e    out) S-grv
      (      i     t         ) S-/
      (      i     t   in    ) S-1
   ;; (      i     t      out) XX
      (r       a             ) (one-shot-press-pcancel 2000 lmeta)
      (r       a       in    ) right
      (r       a          out) pgup
      (  s       o           ) (one-shot-press-pcancel 2000 lalt)
      (  s       o     in    ) up
      (  s       o        out) home
      (    n       t         ) (one-shot-press-pcancel 2000 lctl)
      (    n       t   in    ) down
      (    n       t      out) end
      (      i       e       ) (one-shot-press-pcancel 2000 lshift)
      (      i       e in    ) left
      (      i       e    out) pgdn
      (  s n i               ) tab
      (  s n i         in    ) del
   ;; (  s n i            out) fn
      (          o t e       ) ret
      (          o t e in    ) esc
   ;; (          o t e    out) XX
      (                in    ) spc
      (                   out) bspc
    )
  '';
};}
