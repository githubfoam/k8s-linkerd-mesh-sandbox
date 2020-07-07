IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-rio:
	bash app/deploy-rio.sh

deploy-minikube:
	bash app/deploy-minikube.sh

deploy-minikube-latest:
	bash app/deploy-minikube-latest.sh

deploy-linkerd:
	bash app/deploy-linkerd.sh

deploy-canary-linkerd:
	bash app/deploy-canary-linkerd.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-kind deploy-openesb deploy-dashboard deploy-minikube deploy-istio push-image
