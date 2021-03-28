.PHONY: clean

centos-8: build/centos-8/initrd.img

build/centos-8/initrd.img:
	sudo ./build.sh centos-8

clean:
	sudo rm -rf build