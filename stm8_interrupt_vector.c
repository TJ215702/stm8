/* BASIC INTERRUPT VECTOR TABLE FOR STM8S103/105
 * Applicable to: STM8S103x / STM8S105x
 */
#include "stm8s_conf.h"

typedef void @far (*interrupt_handler_t)(void);

struct interrupt_vector {
    unsigned char        interrupt_instruction;
    interrupt_handler_t  interrupt_handler;
};

@far @interrupt void NonHandledInterrupt(void)
{
    return;
}

/* COSMIC startup entry point */
extern void _stext(void);

/* TIM2 update interrupt handler (formerly named pc_irqhandler) */
extern @far @interrupt void pc_irqhandler(void);

/* ============================================================
 *  Interrupt vector table
 *  IRQ number mapping:
 *    13 = TIM2 Update / Overflow / Break
 *    23 = TIM4 Update / Overflow
 *  Currently only IRQ13 is used; all others are mapped to
 *  NonHandledInterrupt.
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
    {0x82, NonHandledInterrupt},                    /* irq23 = TIM4 UPD/OVF */
    {0x82, NonHandledInterrupt},                    /* irq24 */
    {0x82, NonHandledInterrupt},                    /* irq25 */
    {0x82, NonHandledInterrupt},                    /* irq26 */
    {0x82, NonHandledInterrupt},                    /* irq27 */
    {0x82, NonHandledInterrupt},                    /* irq28 */
    {0x82, NonHandledInterrupt},                    /* irq29 */
};
