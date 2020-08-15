<template>
    <div id="app" class="container m-auto center">
        <div>
            <h2 class="text-red-400 strong mt-2 text-center">
                Number Horde
            </h2>
            <ConnectInput v-if="connection === null" />
            <FireInput v-if="connection !== null" />
        </div>
    </div>
</template>
<script>
import ConnectInput from './components/ConnectInput';
import FireInput from './components/FireInput';

export default {
    name: "App",
    components: {
        ConnectInput,
        FireInput
    },
    data() {
        return {
            connection: null,
        };
    },
    created() {
        console.log("Starting connection to WebSocket Server");
        this.connection = new WebSocket("ws://localhost:9080");
        this.connection.onmessage = async (e) => {
            const encoded = await new Response(e.data).text();
            const pkt = JSON.parse(encoded);

            console.log("Received", pkt, pkt.data);

            this.sendMessage("Good day sir!");
            this.connection.close(1000, "Deliberate disconnection");
        }
        this.connection.onopen = (e) => {
            console.log(e);
            console.log("Successfully connected to the server!");
        }
        this.connection.onerror = (e) => {
            console.log("Error", e);
        }
        this.connection.onclose = (e) => {
            console.log("Connection closed", e);
            this.connection = null;
        }
    },
    methods: {
        connect() {

        },
        sendMessage(message) {
            console.log("Sent:", message);
            this.connection.send(this.createPkt("simple", message));
        },
        createPkt(method, message) {
            return JSON.stringify({
                "method": method,
                "data": {
                    "msg": message
                }
            })
        }
    }
};
</script>
<style>
body {
    @apply text-white bg-black;
}
</style>