;; This will fail with UnsatisfiedLinkError - dll not loaded yet
;(def out (let [out (new java.io.ByteArrayOutputStream) zout (new org.brotli.wrapper.enc.BrotliOutputStream out)] [out zout]))
;; static block in this class loads the library
test.test
;; Now the native calls succeeds
(def out (let [out (new java.io.ByteArrayOutputStream) zout (new org.brotli.wrapper.enc.BrotliOutputStream out)] [out zout]))
;; Compress some data
(dotimes [n 10000] (.write (second out) (rand-int 100)))
(.close (second out))
;; Uncompress it. This prints 10000
(def zin (let [in (new java.io.ByteArrayInputStream (.toByteArray (first out)))  zin (new org.brotli.wrapper.dec.BrotliInputStream in)] [in zin]))
(loop [cnt 0] (print cnt "...") (if (= -1 (.read (second zin))) cnt (recur (inc cnt))))
;; See how much smaller it got (I got ~8500 bytes)
(count (.toByteArray (first out)))
