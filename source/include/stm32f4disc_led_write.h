#ifndef STM32F4DISC_LED_WRITE_H
#define STM32F4DISC_LED_WRITE_H

extern void Disc_GPIO_Led_Init(void);
extern void Disc_GPIO_WriteBit(uint8_t);
extern void Disc_GPIO_ReadBit_Init(void);
extern uint8_t Disc_GPIO_ReadBit(void);

#endif // STM32F4DISC_LED_WRITE_H