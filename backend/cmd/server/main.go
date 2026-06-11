package main

import (
	"log"
	"net/http"

	"caravan-chaos/backend/internal/config"
	"caravan-chaos/backend/internal/httpapi"
)

func main() {
	cfg := config.FromEnv()
	handler := httpapi.NewRouter(cfg)

	log.Printf("caravan-chaos backend listening on %s", cfg.Addr)
	if err := http.ListenAndServe(cfg.Addr, handler); err != nil {
		log.Fatal(err)
	}
}
