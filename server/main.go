package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Welcome to my website, vance!")
	})

	err := http.ListenAndServe(":3000", nil)

	if err != nil {
		panic(err)
	}
}
