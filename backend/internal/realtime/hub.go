package realtime

import "sync"

type Hub struct {
	mu    sync.RWMutex
	rooms map[string]*Room
}

type Room struct {
	ID        string
	ServerSeq int64
}

func NewHub() *Hub {
	return &Hub{
		rooms: make(map[string]*Room),
	}
}

func (h *Hub) GetOrCreateRoom(id string) *Room {
	h.mu.Lock()
	defer h.mu.Unlock()

	room, ok := h.rooms[id]
	if ok {
		return room
	}

	room = &Room{ID: id}
	h.rooms[id] = room
	return room
}
