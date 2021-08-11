# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.

import time
import os
import sys
import asyncio
from six.moves import input

from azure.iot.device.aio import IoTHubModuleClient
from opentelemetry import trace, baggage
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from azure.monitor.opentelemetry.exporter import AzureMonitorTraceExporter

from prometheus_client import start_http_server, Counter


counter_demo = Counter("counter_mock_module", "Demo counter for mock inferencing module")


async def main():
    try:
        if not sys.version >= "3.5.3":
            raise Exception(
                "The sample requires python 3.5.3+. Current version of Python: %s"
                % sys.version
            )
        print("IoT Hub Client for Python")

        # The client object is used to interact with your Azure IoT hub.
        module_client = IoTHubModuleClient.create_from_edge_environment()

        # connect the client.
        await module_client.connect()

        try:
            connection_string = os.environ["ApplicationInsightsConnectionString"]
            exporter = AzureMonitorTraceExporter.from_connection_string(
                connection_string
            )
            trace.set_tracer_provider(TracerProvider())
            span_processor = BatchSpanProcessor(exporter)
            trace.get_tracer_provider().add_span_processor(span_processor)
            tracer = trace.get_tracer(__name__)
        except Exception as ex:
            print("Exception:")
            print(ex)

        # define behavior for receiving an input message on input1
        async def input1_listener(module_client):
            while True:
                input_message = await module_client.receive_message_on_input(
                    "input1"
                )  # blocking call
                with tracer.start_as_current_span(name="parent span"):
                    parent_ctx = baggage.set_baggage("context", "parent")
                    print(f"message received on input1 {input_message.data} ")
                    print(f"custom properties are {input_message.custom_properties}")
                    print("Send message to output1")
                    with tracer.start_as_current_span(
                        name="child span", context=parent_ctx
                    ) as child_span:
                        child_ctx = baggage.set_baggage("context", "child")
                        await module_client.send_message_to_output(
                            input_message, "output1"
                        )
                        counter_demo.inc()

        # define behavior for halting the application
        def stdin_listener():
            while True:
                try:
                    selection = input("Press Q to quit\n")
                    if selection == "Q" or selection == "q":
                        print("Quitting...")
                        break
                except:
                    time.sleep(10)

        # Schedule task for C2D Listener
        listeners = asyncio.gather(input1_listener(module_client))

        print("The sample is now waiting for messages. ")

        # Run the stdin listener in the event loop
        loop = asyncio.get_event_loop()
        user_finished = loop.run_in_executor(None, stdin_listener)

        # Wait for user to indicate they are done listening for messages
        await user_finished

        # Cancel listening
        listeners.cancel()

        # Finally, disconnect
        await module_client.disconnect()

    except Exception as e:
        print("Unexpected error %s " % e)
        raise


if __name__ == "__main__":
    # start metric endpoint
    start_http_server(9600, addr="0.0.0.0")
    
    asyncio.run(main())
