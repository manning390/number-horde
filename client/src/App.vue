<template>
    <div id="app" class="container m-auto center">
        <div>
            <h2 class="text-red-400 strong mt-2 text-center">Number Horde
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
        this.connection = new WebSocket("wss://echo.websocket.org");
        this.connection.onmessage = (e) => {
            console.log(e);
        }
        this.connection.onopen = (e) => {
            console.log(e);
            console.log("Successfully connected to the echo websocket server!");
        }
    },
    methods: {
        sendMessage(message) {
            console.log(this.connection);
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