package v1

//https://github.com/kubernetes/sample-controller/blob/master/pkg/apis/samplecontroller/v1alpha1/types.go

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type Lobby struct {
	metav1.TypeMeta   `json:".inline"`
	metav1.ObjectMeta `json:".metadata.omitempty"`
	Sepc              LobbySpec `json:".spec"`
}

type LobbySpec struct {
	Image   string `json:"image"`
	domain  string `json:"domain"`
	token   string `json:"token"`
	service string `json:"service"`
}

type LobbyList struct {
	metav1.TypeMeta
	metav1.ObjectMeta
	Items []Lobby `json:"items"`
}
