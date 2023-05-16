(use ../build/wjpu)

(init)
(def w (create-window 200 200 "welcome window"))
(pp (close-window? w))
(poll-events)
(pp (close-window? w))
(destroy-window w)

(def ws (map |(create-window 200 200 (string $0)) (range 10)))
(map |(destroy-window $0) ws)

(terminate)




#(defn wait [&]
#  (if (close-window? w)
#    (destroy-window w)
#    (os/sleep 1)))
#(map wait (range 100))
