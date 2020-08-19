<template>
    <div id="app" class="container m-auto center">
        <div>
            <h2 class="title text-red-400 strong mt-2 text-center text-6xl">
                Number Horde
            </h2>
            <div class="text-center" v-if="connection === null">
                Welcome to Number Horde!<br />
                <p class="text">
                    To join a server, punch in the IP and Port below!
                </p>
                <label class="block">
                    <div>Server IP:</div>
                    <input type="text" name="ip" class="rounded-l h-6 text-black p-2 text-center" v-model="ipData" v-on:keyup.enter="connect">
                    <button class="p-1 h-7 bg-blue-500 hover:bg-blue-900 rounded-r" type="submit" v-on:click="connect">Connect</button>
                </label>
            </div>
            <div class="text-center" v-if="connection !== null">
                <input v-model="fireData" class="rounded-l w-3/5 h-6 center my-6 mx-auto p-2 text-center text-black center" type="text" v-on:keyup.enter="fire">
                <button class="bg-red-500 hover:bg-red-900 rounded-r" type="submit" v-on:click="fire">Fire!</button>
                <div class="h-20 w-20 rounded" v-bind:style="charStyle" v-if="!!charStyle">&nbsp;</div>
            </div>
        </div>
    </div>
</template>
<script>
export default {
    name: "App",
    data() {
        return {
            connection: null,
            ipData: "localhost:9080",
            fireData: "",
            charStyle: undefined
        };
    },
    created() {
        this.connect();
    },
    methods: {
        connect() {
            console.log("Starting connection to WebSocket Server");
            this.connection = new WebSocket("ws://" + this.ipData);
            this.connection.onmessage = async (e) => {
                const encoded = await new Response(e.data).text();
                const pkt = JSON.parse(encoded);

                console.log("Received", pkt.method, pkt.data);
                this.charStyle = {
                    'background-color': "#" + pkt.data.color
                };
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
        fire() {
            this.sendMessage("fire", { "shot": this.fireData });
            this.fireData = "";
        },
        sendMessage(method, data = {}) {
            let pkt = {
                "method": method,
                "data": data
            };
            console.log("Sent", pkt);
            this.connection.send(JSON.stringify(pkt));
        },
    }
};
</script>
<style>
body {
    @apply text-white bg-black;
}

.title {
    font-family: 'Buried';
}

@font-face {
    font-family: 'Buried';
    src: url("./fonts/BuriedExtended.eot");
    src:
        url("./fonts/BuriedExtended.woff") format("woff"),
        url("./fonts/BuriedExtended.otf") format("opentype");
    /*url("./fonts/BuriedExteneded.svg#filename") format("svg");*/
}
</style>