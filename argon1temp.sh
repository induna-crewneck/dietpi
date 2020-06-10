			# I2C state
			local rpi_i2c_enabled=$(grep -cm1 '^[[:blank:]]*dtparam=i2c_arm=on' /boot/config.txt)
			local rpi_i2c_text='Off'
			(( $rpi_i2c_enabled )) && rpi_i2c_text='On'
			G_WHIP_MENU_ARRAY+=('I2C state' ": [$rpi_i2c_text]")
