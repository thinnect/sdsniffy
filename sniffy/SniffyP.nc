/**
 * TinyOS radio sniffer that prints packets out over serial. Has a queue and
 * splits a print over several tasks to disrupt radio as little as possible.
 *
 * @author Raido Pahtma
 * @license MIT
 */
module SniffyP {
	uses {
		interface Receive[am_id_t id];
		interface Receive as Snoop[am_id_t id];
		interface AMPacket;
		interface Packet;
		interface PacketField<int8_t> as RSSI;
		interface PacketField<uint8_t> as LQI;
		interface Leds;
		interface PacketTimeStamp<TMilli, uint32_t>;
		interface Queue<message_t*>;
		interface Pool<message_t>;
	}
}
implementation {

	#define __MODUUL__ "sniff"
	#define __LOG_LEVEL__ ( LOG_LEVEL_SniffyP & BASE_LOG_LEVEL )
	#include "log.h"

	enum {
		ST_IDLE,
		ST_LOG_TIMESTAMP,
		ST_LOG_DST,
		ST_LOG_SRC,
		ST_LOG_AMID,
		ST_LOG_LEN,
		ST_LOG_PAYLOAD,
		ST_LOG_LQI,
		ST_LOG_RSSI,
	};

	uint8_t m_state = ST_IDLE;
	message_t* m_msg = NULL;
	uint8_t m_len_logged = 0;
	uint8_t m_len = 0;
	uint8_t* m_payload = NULL;

	task void logtask() {
		switch(m_state) {
			case ST_IDLE:
				if(call Queue.empty() == FALSE) {
					m_msg = call Queue.dequeue();
					m_len = call Packet.payloadLength(m_msg);
					m_payload = call Packet.getPayload(m_msg, m_len);
					m_len_logged = 0;
				}
				else {
					return;
				}
				break;
			case ST_LOG_TIMESTAMP:
				printf("%08"PRIX32",", call PacketTimeStamp.timestamp(m_msg));
				break;
			case ST_LOG_DST:
				printf("%04X,", call AMPacket.destination(m_msg));
				break;
			case ST_LOG_SRC:
				printf("%04X,", call AMPacket.source(m_msg));
				break;
			case ST_LOG_AMID:
				printf("%02X,", call AMPacket.type(m_msg));
				break;
			case ST_LOG_LEN:
				printf("%02X,", m_len);
				break;
			case ST_LOG_PAYLOAD:
				if(m_len_logged < m_len) {
					printf("%02X", m_payload[m_len_logged]);
					m_len_logged++;
					post logtask();
					return;
				}
				printf(",");
				break;
			case ST_LOG_LQI:
				if(call LQI.isSet(m_msg)) {
					printf("%02X,", call LQI.get(m_msg));
				}
				else {
					printf("00,");
				}
				break;
			case ST_LOG_RSSI:
				if(call RSSI.isSet(m_msg)) {
					printf("%i,", call RSSI.get(m_msg));
				}
				else {
					printf("000,");
				}
				break;
			default:
				printf("\n");
				call Pool.put(m_msg);
				m_msg = NULL;
				m_state = ST_IDLE;
				return;
		}
		m_state++;
		post logtask();
	}

	inline message_t* receive(message_t* msg) {
		message_t* ret = call Pool.get();
		if(ret != NULL) {
			if(call Queue.enqueue(msg) == SUCCESS) {
				call Leds.led1Toggle();
				post logtask();
				return ret;
			}
			else {
				call Pool.put(ret);
			}
		}
		call Leds.led2Toggle();
		return msg;
	}

	event message_t* Receive.receive[am_id_t id](message_t *msg, void *payload, uint8_t len) {
		return receive(msg);
	}

	event message_t* Snoop.receive[am_id_t id](message_t *msg, void *payload, uint8_t len) {
		return receive(msg);
	}

}
