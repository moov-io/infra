package code

import (
	"encoding/json"
)

type Credentials struct {
	Username string
	Password string `json:"-"`
}

func (c Credentials) MarshalJSON() ([]byte, error) {
	type Aux struct {
		Username string
		Password string
	}
	return json.Marshal(Aux{
		Username: c.Username,
		Password: mask(c.Password),
	})
}

func mask(input string) string {
	return "****"
}
