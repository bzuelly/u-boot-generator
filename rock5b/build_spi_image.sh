SPI_IMAGE=./spi_image.img

generate_spi_image() {
	dd if=/dev/zero of=$SPI_IMAGE bs=1M count=0 seek=16
	parted -s $SPI_IMAGE mklabel gpt
	parted -s $SPI_IMAGE unit s mkpart idbloader 64 7167
	parted -s $SPI_IMAGE unit s mkpart vnvm 7168 7679
	parted -s $SPI_IMAGE unit s mkpart reserved_space 7680 8063
	parted -s $SPI_IMAGE unit s mkpart reserved1 8064 8127
	parted -s $SPI_IMAGE unit s mkpart uboot_env 8128 8191
	parted -s $SPI_IMAGE unit s mkpart reserved2 8192 16383
	parted -s $SPI_IMAGE unit s mkpart uboot 16384 32734

	if [ -e "./idbloader.img" ] && [ -e "./u-boot.itb" ]; then
		dd if=./idbloader.img of=$SPI_IMAGE seek=64 conv=notrunc
		dd if=./u-boot.itb of=$SPI_IMAGE seek=16384 conv=notrunc
	else
		dd if=${OUT}/u-boot/idbloader.img of=$SPI_IMAGE seek=64 conv=notrunc
		dd if=${OUT}/u-boot/u-boot.itb of=$SPI_IMAGE seek=16384 conv=notrunc
	fi
}
generate_spi_image
