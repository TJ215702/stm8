/*  BASIC INTERRUPT VECTOR TABLE FOR STM8S103/105
 *  適用：STM8S103x / STM8S105x
 */
#include "stm8s_conf.h"

typedef void @far (*interrupt_handler_t)(void);

struct interrupt_vector {
    unsigned char        interrupt_instruction;
    interrupt_handler_t  interrupt_handler;
};

@far @interrupt void NonHandledInterrupt(void)
{
    /* 開發階段可以在這裡下 breakpoint，抓未知中斷 */
    return;
}

/* COSMIC 啟動程式入口 */
extern void _stext(void);

/* 你的 TIM2 update 中斷 handler（原本叫 pc_irqhandler） */
extern @far @interrupt void pc_irqhandler(void);

/* ============================================================
 *  Interrupt vector table
 *  irq 編號對照：
 *    13 = TIM2 Update/Overflow/Break
 *    23 = TIM4 Update/Overflow
 *  目前只用 irq13，其它都指到 NonHandledInterrupt。
 * ============================================================ */
struct interrupt_vector const _vectab[] = {
    {0x82, (interrupt_handler_t)_stext},            /* RESET */
    {0x82, NonHandledInterrupt},                    /* TRAP */
    {0x82, NonHandledInterrupt},                    /* irq0  */
    {0x82, NonHandledInterrupt},                    /* irq1  */
    {0x82, NonHandledInterrupt},                    /* irq2  */
    {0x82, NonHandledInterrupt},                    /* irq3  */
    {0x82, NonHandledInterrupt},                    /* irq4  */
    {0x82, NonHandledInterrupt},                    /* irq5  */
    {0x82, NonHandledInterrupt},                    /* irq6  */
    {0x82, NonHandledInterrupt},                    /* irq7  */
    {0x82, NonHandledInterrupt},                    /* irq8  */
    {0x82, NonHandledInterrupt},                    /* irq9  */
    {0x82, NonHandledInterrupt},                    /* irq10 */
    {0x82, NonHandledInterrupt},                    /* irq11 */
    {0x82, NonHandledInterrupt},                    /* irq12 */

    /* ★ 這一個是 TIM2 Update/Overflow/Break → 你的 pc_irqhandler */
    {0x82, (interrupt_handler_t)pc_irqhandler},     /* irq13 */

    {0x82, NonHandledInterrupt},                    /* irq14 */
    {0x82, NonHandledInterrupt},                    /* irq15 */
    {0x82, NonHandledInterrupt},                    /* irq16 */
    {0x82, NonHandledInterrupt},                    /* irq17 */
    {0x82, NonHandledInterrupt},                    /* irq18 */
    {0x82, NonHandledInterrupt},                    /* irq19 */
    {0x82, NonHandledInterrupt},                    /* irq20 */
    {0x82, NonHandledInterrupt},                    /* irq21 */
    {0x82, NonHandledInterrupt},                    /* irq22 */

    /* 若未來要用 TIM4 Update，可以把這行改成對應的 isr */
    {0x82, NonHandledInterrupt},                    /* irq23 = TIM4 UPD/OVF */

    {0x82, NonHandledInterrupt},                    /* irq24 */
    {0x82, NonHandledInterrupt},                    /* irq25 */
    {0x82, NonHandledInterrupt},                    /* irq26 */
    {0x82, NonHandledInterrupt},                    /* irq27 */
    {0x82, NonHandledInterrupt},                    /* irq28 */
    {0x82, NonHandledInterrupt},                    /* irq29 */
};
