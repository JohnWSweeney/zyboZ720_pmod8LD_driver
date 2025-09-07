#include "xgpiops.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(void){
	static const u32 mioLED = 7;
	static const u32 mioPmod[8] = {13, 10, 11, 12, 0, 9, 14, 15};

	XGpioPs gpioPS;
	XGpioPs_Config *cfg = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	XGpioPs_CfgInitialize(&gpioPS, cfg, cfg->BaseAddr);
	XGpioPs_SetDirectionPin(&gpioPS, mioLED, 1);
	XGpioPs_SetOutputEnablePin(&gpioPS, mioLED, 1);
	XGpioPs_WritePin(&gpioPS, mioLED, 0);

	// initialize MIO Pmod J4 pins as outputs, set low. Pmod 8LD connected.
	for(int i=0;i<8;i++){
		XGpioPs_SetDirectionPin(&gpioPS, mioPmod[i], 1);
		XGpioPs_SetOutputEnablePin(&gpioPS, mioPmod[i], 1);
		XGpioPs_WritePin(&gpioPS, mioPmod[i], 0);
	}

	XGpio gpioRGB;
	XGpio_Initialize(&gpioRGB, XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_SetDataDirection(&gpioRGB, 1, 0x0);
	XGpio_DiscreteWrite(&gpioRGB, 1, 0x0);
	///
	XGpio_SetDataDirection(&gpioRGB, 2, 0x0);
	XGpio_DiscreteWrite(&gpioRGB, 2, 0x0);

	printf("entering while loop.\n");
	static u32 mioLEDstatus = 0;
	static u8 mask1 = 1;
	static u32 incr = 0;
	static u32 blueIncr = 0;
	while(1){
		if(incr==500){
			mioLEDstatus ^= 1;
			XGpioPs_WritePin(&gpioPS, mioLED, mioLEDstatus);
			incr = 0;
		}
		//
		if(blueIncr==65){
			mask1 ^= 1U;
			XGpio_DiscreteWrite(&gpioRGB, 2, mask1);
			blueIncr = 0;
		}
		incr++;
		blueIncr++;
		usleep(1000); // 1ms
	}
}
