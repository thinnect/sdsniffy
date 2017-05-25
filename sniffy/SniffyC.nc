/**
 * TinyOS radio sniffer that prints packets out over serial. Has a queue and
 * splits a print over several tasks to disrupt radio as little as possible.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "loglevels.h"
configuration SniffyC { }
implementation {

	#define SNIFFY_POOL_SIZE 50

    components SniffyP;

	components MainC;

	components new Boot2SplitControlC("bt", "pf") as BootPrintf;
	BootPrintf.Boot -> MainC.Boot;

	components StartPrintfC;
	BootPrintf.SplitControl -> StartPrintfC;

	components PlatformActiveMessageC as Radio;

	components new Boot2SplitControlC("pf", "rdo") as BootRadio;
	BootRadio.Boot -> StartPrintfC.Boot;
	BootRadio.SplitControl -> Radio;

	SniffyP.Receive -> Radio.Receive;
	SniffyP.Snoop -> Radio.Snoop;

	SniffyP.RSSI -> Radio.PacketSignalStrength;
	SniffyP.LQI -> Radio.PacketLinkQuality;

	SniffyP.AMPacket -> Radio.AMPacket;
	SniffyP.PacketTimeStamp -> Radio.PacketTimeStampMilli;
	SniffyP.Packet -> Radio.Packet;

	components new PoolC(message_t, SNIFFY_POOL_SIZE);
	SniffyP.Pool -> PoolC;

	components new QueueC(message_t*, SNIFFY_POOL_SIZE);
	SniffyP.Queue -> QueueC;

	components LedsC;
	SniffyP.Leds -> LedsC;

#ifdef USE_BLINKY
	components new BlinkyC(5*1024UL, 64);
#endif

}
