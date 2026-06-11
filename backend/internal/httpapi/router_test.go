package httpapi

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"caravan-chaos/backend/internal/config"
)

func TestHealthRoute(t *testing.T) {
	handler := NewRouter(config.Config{Addr: ":0"})
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected %d, got %d", http.StatusOK, rec.Code)
	}
	if rec.Body.String() == "" {
		t.Fatal("expected health response body")
	}
}

func TestRoomsRouteRequiresPost(t *testing.T) {
	handler := NewRouter(config.Config{Addr: ":0"})
	req := httptest.NewRequest(http.MethodGet, "/v1/rooms", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusMethodNotAllowed {
		t.Fatalf("expected %d, got %d", http.StatusMethodNotAllowed, rec.Code)
	}
}
