#include "stm32f4disc_led_write.h"

void Disc_GPIO_Led_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	// Enable GPIO Clock
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);
	// Configure the GPIO_LED pins
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_PuPd  = GPIO_PuPd_NOPULL;

    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_12|GPIO_Pin_13|GPIO_Pin_14|GPIO_Pin_15;
    GPIO_Init(GPIOD, &GPIO_InitStructure);
}

void Disc_GPIO_WriteBit(uint8_t BitVal)
{
	// turn on the LEDs
    if (BitVal)
    {
        
        GPIOD->BSRRL = GPIO_Pin_13|GPIO_Pin_15;
        GPIOD->BSRRH = GPIO_Pin_12|GPIO_Pin_14;
    }
    else
    {
        GPIOD->BSRRL = GPIO_Pin_12|GPIO_Pin_14;
        GPIOD->BSRRH = GPIO_Pin_13|GPIO_Pin_15;
    }
}

void Disc_GPIO_ReadBit_Init(void)
{
    // GPIOA Periph clock enable
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);

    // Configure the pin as input using the stdperiph_lib calls
    GPIO_InitTypeDef  GPIO_InitStructure;
    // Configure User Push Button
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;

    GPIO_Init(GPIOA, &GPIO_InitStructure);    
}

uint8_t Disc_GPIO_ReadBit(void)
{
    if (GPIOA->IDR&0x0001)
    {
        uint8_t BitVal=0x0001;
        return BitVal;
    }
    else
    {
        uint8_t BitVal=0x0000;
        return BitVal;
    }
        
}