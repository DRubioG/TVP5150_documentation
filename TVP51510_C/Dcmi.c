/*
DCMI_Stand for ucos II 
*/

/*
create by xingyanchen (a chinese) 作者：邢延晨(xyc)
create time 2015-9-9
*/
/*******************************************************************************
*  *******      ***********      ****    *****     *****          *************          *
*  *******      **********       ****    ******    *****        ******** ********        *
*  *******      *********                *******   *****       *******      ******       *
*    *******   *********         ****    ********  *****      ******        ******       *
*      ******* ********          ****    ********* *****     ******         ******       *
*        **********              ****    ***************     ******                      *
*          ******                ****    ***** *********     ******      **********      *
*        ****  *****             ****    *****  ********     *******     **********      *                                                                          *
*      ****     ********         ****    *****   *******      *******       *******      *
*   ****         ********        ****    *****    ******       ******** ****** ****      *
* ***             *********      ****    *****     *****         ************  ****      *
*******************************************************************************/

#include "Dcmi.h"


u32 Line_times,FRAME_Times,VSYNC_Times;
u8 viod_buffer[90000];
u16  number;



/*****************************************************************************
初始化DCMI interface
函数名:Init_DCMI
参  数:void
返回数:void
*****************************************************************************/
void Init_DCMI_GPIO(void)
{
  
  GPIO_InitTypeDef GPIO_InitStructure;

  /*** Configures the DCMI GPIOs to interface with the OV2640 camera module ***/
  /* Enable DCMI GPIOs clocks */
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA | RCC_AHB1Periph_GPIOB | RCC_AHB1Periph_GPIOC | 
                         RCC_AHB1Periph_GPIOE, ENABLE);

  /* Connect DCMI pins to AF13 */
  GPIO_PinAFConfig(GPIOA, GPIO_PinSource4, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOA, GPIO_PinSource6, GPIO_AF_DCMI);


  GPIO_PinAFConfig(GPIOB, GPIO_PinSource6, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOB, GPIO_PinSource7, GPIO_AF_DCMI);

	
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource6, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource7, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource8, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource9, GPIO_AF_DCMI);


  GPIO_PinAFConfig(GPIOE, GPIO_PinSource4, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOE, GPIO_PinSource5, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOE, GPIO_PinSource6, GPIO_AF_DCMI);

 
  /* DCMI GPIO configuration */
  /* D0..D4(PH9/10/11/12/14), HSYNC(PH8) */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6 | GPIO_Pin_7 | GPIO_Pin_8 | 
                                GPIO_Pin_9 ;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_OD;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP ;
  GPIO_Init(GPIOC, &GPIO_InitStructure);

  /* D5..D7(PI4/6/7), VSYNC(PI5) */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_6 | GPIO_Pin_4;
  GPIO_Init(GPIOE, &GPIO_InitStructure);

  /* D5..D7(PI4/6/7), VSYNC(PI5) */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4 | GPIO_Pin_6;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* D5..D7(PI4/6/7), VSYNC(PI5) */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6 | GPIO_Pin_7;
  GPIO_Init(GPIOB, &GPIO_InitStructure);

  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

  /* Configure PG6 and PG8 in output pushpull mode */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOD, &GPIO_InitStructure);  
//
//	TVPReset = 1;
//	Delay_ms(550);
//	TVPReset = 0;
//	Delay_ms(90);
//	TVPReset = 1;

}
//{
//  GPIO_InitTypeDef GPIO_InitStructure;
//  
//  
//  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA | RCC_AHB1Periph_GPIOB | RCC_AHB1Periph_GPIOC | 
//                         RCC_AHB1Periph_GPIOE, ENABLE);//使能各个时钟
//  //先将各个管脚挂接在IO口上
//  
//  GPIO_PinAFConfig(GPIOA, GPIO_PinSource4, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOA, GPIO_PinSource6, GPIO_AF_DCMI);
//  //DCMI_HSYNC DCMI_PIXCLK
//  
//  GPIO_PinAFConfig(GPIOB, GPIO_PinSource6, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOB, GPIO_PinSource7, GPIO_AF_DCMI);
//  //DCMI_D5  DCMI_VSYNC
//  
//  GPIO_PinAFConfig(GPIOC, GPIO_PinSource6, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOC, GPIO_PinSource7, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOC, GPIO_PinSource8, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOC, GPIO_PinSource9, GPIO_AF_DCMI);
//  //DCMI_D0 DCMI_D1
//  
//  
//
//  GPIO_PinAFConfig(GPIOE, GPIO_PinSource4, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOE, GPIO_PinSource6, GPIO_AF_DCMI);
//  GPIO_PinAFConfig(GPIOE, GPIO_PinSource5, GPIO_AF_DCMI);
//  //DCMI_D2 DCMI_D3 DCMI_D4 DCMI_D六 DCMI_D7
//  
//  
//  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
//  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
//  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
//  GPIO_InitStructure.GPIO_OType = GPIO_OType_OD;
//  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4 | GPIO_Pin_6;
//  GPIO_Init(GPIOA, &GPIO_InitStructure);
//  //A 的 4和六连接上去
//  
//  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7 | GPIO_Pin_6;
//  GPIO_Init(GPIOB, &GPIO_InitStructure);
//  //GPIO_B的6 和 7 连接到
//  //DCMI_D5  DCMI_VSYNC
//  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7 | GPIO_Pin_6 | GPIO_Pin_8 | GPIO_Pin_9;
//  GPIO_Init(GPIOC, &GPIO_InitStructure);
//  //GPIO_C的6 和 7 连接到
//  //DCMI_D0 DCMI_D1
//  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
//  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
//  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
//  GPIO_InitStructure.GPIO_OType = GPIO_OType_OD;
//  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4 | GPIO_Pin_5 | GPIO_Pin_6;
//  GPIO_Init(GPIOE, &GPIO_InitStructure);
//  
//  
//  
//  //此处应该重启TVP，先观测看看是否需要重启！
//  
//  
//
//}

/*****************************************************************************
初始化DCMI配置
函数名:DCMI_Init
参  数:void
返回数:void
*****************************************************************************/
#define DCMI_DR_ADDRESS       0x50050028
#define LCD_ADDERSS           0x60100000
DMA_InitTypeDef  DMA_InitStructure;	
void DCMI_Init_Pra(void)
{

	
	
	DCMI_InitTypeDef DCMI_InitStructure;
	

	
	/*** Configures the DCMI to interface with the OV9655 camera module ***/
	/* Enable DCMI clock */
	RCC_AHB2PeriphClockCmd(RCC_AHB2Periph_DCMI, ENABLE);

//        DCMI_CodesInitTypeDef   DCMI_CodesInitStructure;
//        
//        DCMI_CodesInitStructure.DCMI_FrameStartCode = 0x7C;
//        DCMI_CodesInitStructure.DCMI_FrameStartCode = 0x9D;
//        DCMI->ESUR =  0x10;
//        
//        DCMI_SetEmbeddedSynchroCodes(&DCMI_CodesInitStructure);
        
        
	/* DCMI configuration */ 
	DCMI_InitStructure.DCMI_CaptureMode = DCMI_CaptureMode_Continuous;
	DCMI_InitStructure.DCMI_SynchroMode = DCMI_SynchroMode_Hardware;
	DCMI_InitStructure.DCMI_PCKPolarity = DCMI_PCKPolarity_Rising;
	DCMI_InitStructure.DCMI_VSPolarity = DCMI_VSPolarity_Low;
	DCMI_InitStructure.DCMI_HSPolarity = DCMI_HSPolarity_High;
	DCMI_InitStructure.DCMI_CaptureRate = DCMI_CaptureRate_All_Frame;
	DCMI_InitStructure.DCMI_ExtendedDataMode = DCMI_ExtendedDataMode_8b;
	/* DCMI configuration */ 
	DCMI_Init(&DCMI_InitStructure);
	
	
	/* Configures the DMA2 to transfer Data from DCMI */
	/* Enable DMA2 clock */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_DMA2, ENABLE);

	/* DMA2 Stream1 Configuration */
	DMA_DeInit(DMA2_Stream1);
	while (DMA_GetCmdStatus(DMA2_Stream1) != DISABLE)
	{
	}
	DMA_InitStructure.DMA_Channel = DMA_Channel_1;
	DMA_InitStructure.DMA_PeripheralBaseAddr = DCMI_DR_ADDRESS;
	DMA_InitStructure.DMA_Memory0BaseAddr = (u32)viod_buffer;//LCD_ADDERSS;
// 	DMA_InitStructure.DMA_Memory0BaseAddr = FSMC_LCD_ADDRESS;  
  
	DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralToMemory;
 DMA_InitStructure.DMA_BufferSize = 22500;
// 	DMA_InitStructure.DMA_BufferSize = 1;	
	DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
 DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
// 	DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Disable;  
  
	DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Word;
	DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Word;
	DMA_InitStructure.DMA_Mode = DMA_Mode_Circular;
	DMA_InitStructure.DMA_Priority = DMA_Priority_VeryHigh;
	DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Enable;
	DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_Full;
	DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
	DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;

	/* DMA2 IRQ channel Configuration */
	DMA_Init(DMA2_Stream1, &DMA_InitStructure); 

	DMA_ITConfig(DMA2_Stream1, DMA_IT_TC, ENABLE);

	/* DMA Stream enable */
	DMA_Cmd(DMA2_Stream1, ENABLE);
	while ((DMA_GetCmdStatus(DMA2_Stream1) != ENABLE))
	{
	}
   NVIC_InitTypeDef NVIC_InitStructure;
////        
//          NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);
////  NVIC_InitStructure.NVIC_IRQChannel = DMA2_Stream1_IRQn;
////  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
////  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;
////  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
////  NVIC_Init(&NVIC_InitStructure);   
////  
NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
  NVIC_InitStructure.NVIC_IRQChannel = DCMI_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
         DCMI_ITConfig(DCMI_IT_LINE, ENABLE);
       
//         DCMI_ITConfig(DCMI_IT_FRAME, ENABLE);
}
//{
//  DCMI_InitTypeDef DCMI_InitStructure;
//  DMA_InitTypeDef  DMA_InitStructure;
//  NVIC_InitTypeDef NVIC_InitStructure;
//  DCMI_CodesInitTypeDef   DCMI_CodesInitStructure;
//  /*** Configures the DCMI to interface with the OV9655 camera module ***/
//  /* Enable DCMI clock */
//  RCC_AHB2PeriphClockCmd(RCC_AHB2Periph_DCMI, ENABLE);
//  
//  /* DCMI configuration */ 
//  DCMI_InitStructure.DCMI_CaptureMode = DCMI_CaptureMode_Continuous;
//  DCMI_InitStructure.DCMI_SynchroMode = DCMI_SynchroMode_Hardware;
//  DCMI_InitStructure.DCMI_PCKPolarity = DCMI_PCKPolarity_Falling;
//  DCMI_InitStructure.DCMI_VSPolarity = DCMI_VSPolarity_High;
//  DCMI_InitStructure.DCMI_HSPolarity = DCMI_HSPolarity_High;
//  DCMI_InitStructure.DCMI_CaptureRate = DCMI_CaptureRate_All_Frame;
//  DCMI_InitStructure.DCMI_ExtendedDataMode = DCMI_ExtendedDataMode_8b;
//  
//  /* Configures the DMA2 to transfer Data from DCMI */
//  /* Enable DMA2 clock */
//  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_DMA2, ENABLE);
//  
//  /* DMA2 Stream1 Configuration */
//  DMA_DeInit(DMA2_Stream1);
//  
//  DMA_InitStructure.DMA_Channel = DMA_Channel_1;  
//  DMA_InitStructure.DMA_PeripheralBaseAddr = DCMI->DR;	
//  DMA_InitStructure.DMA_Memory0BaseAddr = (u32)&viod_buffer;//0x20000000;//FSMC_LCD_ADDRESS;
//  DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralToMemory;
//  DMA_InitStructure.DMA_BufferSize = 32000;// (320 * 240 * 2 / 4) / 16;//1
//  DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
//  DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;//DMA_MemoryInc_Disable;
//  DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Word;
//  DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Word;
//  DMA_InitStructure.DMA_Mode =DMA_Mode_Circular;// DMA_Mode_Normal;//DMA_Mode_Circular;
//  DMA_InitStructure.DMA_Priority = DMA_Priority_VeryHigh;
//  DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Enable;
//  DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_Full;
//  DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
//  DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;
//  
////  NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);
////  NVIC_InitStructure.NVIC_IRQChannel = DMA2_Stream1_IRQn;
////  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
////  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;
////  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
////  NVIC_Init(&NVIC_InitStructure);   
////  
////  //NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
////  NVIC_InitStructure.NVIC_IRQChannel = DCMI_IRQn;
////  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;
////  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;
////  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
////  NVIC_Init(&NVIC_InitStructure);
//  
//  
//  
//  DCMI_CodesInitStructure.DCMI_FrameEndCode  = 0x10;
//  
//  /* DCMI configuration */
//  DCMI_Init(&DCMI_InitStructure);
//  
//  /* DMA2 IRQ channel Configuration */
//  DMA_Init(DMA2_Stream1, &DMA_InitStructure);
//  DMA_ITConfig( DMA2_Stream1, DMA_IT_TC, ENABLE);
//  
//  
//  
////  DCMI_SetEmbeddedSynchroCodes(&DCMI_CodesInitStructure);
////  
////  DCMI_ITConfig(DCMI_IT_FRAME, ENABLE);
////  DCMI_ITConfig(DCMI_IT_OVF, ENABLE);
////  DCMI_ITConfig(DCMI_IT_ERR, ENABLE);
////  DCMI_ITConfig(DCMI_IT_VSYNC, ENABLE);
//}


void DCMI_IRQHandler(void)
{
//	if (DCMI->RISR & DCMI_IT_ERR)
//	{
////		STM_EVAL_LEDOn(LED1);
////		DMA_Cmd(DMA2_Stream1, DISABLE); 
////		DCMI_Cmd(DISABLE); 
////		DCMI_Init_Pra();
////		DMA_Cmd(DMA2_Stream1, ENABLE); 
////		DCMI_Cmd(ENABLE); 
//		DCMI->ICR = DCMI_IT_ERR;
//	}
//	if (DCMI->RISR & DCMI_IT_OVF)
//	{
//		//STM_EVAL_LEDOn(LED2);
////		DMA_Cmd(DMA2_Stream1, DISABLE); 
////		DCMI_Cmd(DISABLE); 
////		DCMI_Init_Pra();
////		DMA_Cmd(DMA2_Stream1, ENABLE); 
////		DCMI_Cmd(ENABLE); 
//	DCMI->ICR = DCMI_IT_OVF;
//	}
	if (DCMI->RISR & DCMI_IT_VSYNC)
	{
		DCMI->ICR = DCMI_IT_VSYNC;
                VSYNC_Times++;
                            if(VSYNC_Times>=2){
		
                DMA_Cmd(DMA2_Stream1, DISABLE); 
		DCMI_Cmd(DISABLE);
            }else if (VSYNC_Times==1)
            {
              
              Line_times = 0;
            }
	}
	if (DCMI->RISR & DCMI_IT_FRAME)
	{
           FRAME_Times++;
           DCMI->ICR = DCMI_IT_FRAME;

//           if(FRAME_Times>=250)
//           {
//             DMA_Cmd(DMA2_Stream1, DISABLE); 
//		DCMI_Cmd(DISABLE); 
//           }

           
	}
  
  if (DCMI->RISR & DCMI_IT_LINE)
  {
Line_times++;
   if((VSYNC_Times>=1)&&(Line_times > 10))
   {
      DMA_Cmd(DMA2_Stream1, DISABLE); 
		DCMI_Cmd(DISABLE); 
     
   }

    DCMI->ICR = DCMI_IT_LINE;
  
    }
  
}


