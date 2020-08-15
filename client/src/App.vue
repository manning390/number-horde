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
            const text = await new Response(e.data).text();
            console.log("Received", text);
            this.sendMessage(text);
        }
        this.connection.onopen = (e) => {
            console.log(e);
            console.log("Successfully connected to the server!");
        }
    },
    methods: {
        sendMessage(message) {
            console.log("Sent:", message);
            this.connection.send(message);
        },
    }
};
</script>
<style>
body {
    @apply text-white bg-black;
}
</style>