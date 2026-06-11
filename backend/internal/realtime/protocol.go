package realtime

type ClientMessage struct {
	Type      string       `json:"type"`
	RoomID    string       `json:"roomId"`
	ClientSeq int64        `json:"clientSeq"`
	Action    PlayerAction `json:"action"`
}

type PlayerAction struct {
	Kind      string `json:"kind"`
	CaravanID string `json:"caravanId,omitempty"`
	Space     int    `json:"space,omitempty"`
	MarkType  string `json:"markType,omitempty"`
}

type ServerMessage struct {
	Type      string      `json:"type"`
	RoomID    string      `json:"roomId"`
	ServerSeq int64       `json:"serverSeq"`
	Events    []RoomEvent `json:"events"`
	State     any         `json:"state,omitempty"`
}

type RoomEvent struct {
	Kind      string `json:"kind"`
	CaravanID string `json:"caravanId,omitempty"`
	Steps     int    `json:"steps,omitempty"`
	Space     int    `json:"space,omitempty"`
}
