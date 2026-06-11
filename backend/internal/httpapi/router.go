package httpapi

import (
	"encoding/json"
	"net/http"
	"time"

	"caravan-chaos/backend/internal/config"
)

type Router struct {
	cfg     config.Config
	started time.Time
}

func NewRouter(cfg config.Config) http.Handler {
	router := &Router{
		cfg:     cfg,
		started: time.Now().UTC(),
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", router.handleHealth)
	mux.HandleFunc("/v1/rooms", router.handleRooms)
	mux.HandleFunc("/v1/realtime", router.handleRealtime)
	return mux
}

func (r *Router) handleHealth(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"status":    "ok",
		"startedAt": r.started.Format(time.RFC3339),
	})
}

func (r *Router) handleRooms(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed")
		return
	}

	writeJSON(w, http.StatusAccepted, map[string]any{
		"status": "stub",
		"next":   "create room state and persist it to Postgres",
	})
}

func (r *Router) handleRealtime(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed")
		return
	}

	writeJSON(w, http.StatusNotImplemented, map[string]any{
		"status": "stub",
		"next":   "upgrade this endpoint to WebSocket room transport",
	})
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func writeError(w http.ResponseWriter, status int, code string) {
	writeJSON(w, status, map[string]any{"error": code})
}
