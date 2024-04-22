import asyncio
import ssl
import websockets
import logging


async def echo(websocket, path):
    async for message in websocket:
        await websocket.send(message)


def main():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # SSL context setup for Secure WebSocket (wss://)
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain('certificate.pem', 'key.pem')

    # Create a new event loop and set it as the current one
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    # Define the WebSocket server (ws://)
    start_server_ws = websockets.serve(echo, "localhost", 8765)
    loop.run_until_complete(start_server_ws)
    logging.info("WebSocket server started on ws://localhost:8765")
    
    # Define the Secure WebSocket server (wss://)
    start_server_wss = websockets.serve(echo,
                                        "localhost", 8766, ssl=ssl_context)
    loop.run_until_complete(start_server_wss)
    logging.info("Secure WebSocket server started on wss://localhost:8766")

    # Start and run the servers
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass
    finally:
        loop.close()
        logging.info("WebSocket servers stopped.")


if __name__ == "__main__":
    main()
