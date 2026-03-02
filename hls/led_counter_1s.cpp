#include <ap_int.h>

// 200 MHz -> 1 second = 200,000,000 cycles
static const ap_uint<32> CLK_HZ = 200000000;

void led_counter_1s(ap_uint<4> &leds) {
#pragma HLS INTERFACE ap_none port=leds
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS PIPELINE II=1

    static ap_uint<32> sec_cnt = 0;
    static ap_uint<4>  val     = 0;

#pragma HLS RESET variable=sec_cnt
#pragma HLS RESET variable=val

    if (sec_cnt == (CLK_HZ - 1)) {
        sec_cnt = 0;
        val = val + 1;
    } else {
        sec_cnt = sec_cnt + 1;
    }

    leds = val;
}
