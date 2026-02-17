package code

type Config struct {
	Secret string `json:"-"` // G117 (gosec)
}
