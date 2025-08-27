.PHONY: init run test shell
init:
	bash scripts/setup.sh
run:
	bash scripts/run_app.sh
test:
	. .venv/bin/activate && bash scripts/ci_test_gui.sh
shell:
	docker run --rm -it -v "$(pwd)":/work -w /work devwx:22.04
