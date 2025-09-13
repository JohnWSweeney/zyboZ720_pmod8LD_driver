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

	// Pmod 8LD connected to MIO J4, initialize as outputs, set low.
	for(int i=0;i<8;i++){
		XGpioPs_SetDirectionPin(&gpioPS, mioPmod[i], 1);
		XGpioPs_SetOutputEnablePin(&gpioPS, mioPmod[i], 1);
		XGpioPs_WritePin(&gpioPS, mioPmod[i], 0);
	}
	// initialize AXI GPIO pwmCNTL.
	// channel 1: 3 enable bits (2 downto 0), red(0), green(1), blue(2).
	// channel 2: duty cycle (7 downto o) 0 to 100%.
	XGpio gpioPwmCntl;
	XGpio_Initialize(&gpioPwmCntl, XPAR_PWMCNTL_DEVICE_ID);
	XGpio_SetDataDirection(&gpioPwmCntl, 1, 0x0);
	XGpio_DiscreteWrite(&gpioPwmCntl, 1, 0x0);
	XGpio_SetDataDirection(&gpioPwmCntl, 2, 0x0);
	XGpio_DiscreteWrite(&gpioPwmCntl, 2, 0x0);
	///
	static u32 mioLEDstatus = 0;
	static u32 timer1 = 0;
	static u32 timer2 = 0;
	printf("entering while loop.\n");
	srand(666);

	while(1){
		if(timer1==500){
			mioLEDstatus ^= 1;
			XGpioPs_WritePin(&gpioPS, mioLED, mioLEDstatus);
			timer1 = 0;
		}
		//
		if(timer2==100){
			XGpio_DiscreteWrite(&gpioPwmCntl, 1, 4);
			u8 rando = rand() % (50 - 1 + 1) + 1;
			XGpio_DiscreteWrite(&gpioPwmCntl, 2, rando);
			timer2 = 0;
		}
		//
		timer1++;
		timer2++;
		usleep(1000); // 1ms
	}
}
