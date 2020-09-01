<template>
    <div id="app" class="container m-auto center">
        <div>
            <h2 class="title text-red-400 strong mt-2 text-center text-6xl">
                Number Horde
            </h2>
            <div class="text-center" v-if="clientState === ClientState.disconnected">
                Welcome to Number Horde!<br />
                <p class="text my-2">
                    To join a server, punch in the IP and Port below!
                </p>
                <div class="text-center text-red-400 my-2" v-if="!!error">
                    {{ error }}
                </div>
                <label class="mx-auto inline-block">
                    <span class="mb-2 inline-block">Server IP</span>
                    <div class="flex">
                        <input type="text" class="p-3 leading-none rounded-l-lg text-black text-center " v-model="ipData" v-on:keyup.enter="connect" placeholder="127.0.0.1:9080">
                        <button class="bg-blue-500 px-6 rounded-r-lg text-white font-bond" v-on:click="connect">Connect</button>
                    </div>
                </label>
            </div>
            <div class="text-center" v-if="clientState === ClientState.connecting">
                Connecting to server...
            </div>
            <div class="text-center" v-if="clientState === ClientState.connected">
                <div v-if="gameState === GameState.lobby">
                    Night is falling...
                </div>
                <div v-if="gameState === GameState.shooting || gameState === GameState.miss">
                    <label class="mx-auto inline-block select-none">
                        <span class="mb-2 inline-block">Load your answer and fire!</span>
                        <div class="flex">
                            <input ref="fire" class="p-3 leading-none rounded-l-lg text-black text-center" type="text" autofocus pattern="\d*" inputmode="numeric" :disabled="gameState === GameState.miss" v-on:keyup.enter="fire" v-model="fireData">
                            <button class="px-6 rounded-r-lg text-white font-bold bg-red-500 hover:bg-red-800 focus:bg-red-800" :disabled="gameState === GameState.miss" v-on:click="fire">Fire!</button>
                        </div>
                    </label>
                    <div class="mx-auto p-1 m-4 rounded w-3/4 bg-gray-900">
                        You're connected as <span class="text-white px-1 rounded-sm font-bold" v-bind:style="charStyle">{{ name }}</span>!
                        <hr class="bg-gray-700 m-2">
                        <h3 class="text-md" v-if="!history.length">Get brain blast'n!</h3>
                        <h3 class="text-md" v-if="!!history.length">Past shots!</h3>
                        <div v-for="data in history" v-bind:key="data.id">
                            <span>{{ data.equation }} = {{ data.answer }} => <span v-bind:class="{'text-red-500': data.first, 'font-bold': data.first}">{{ data.points}}</span></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
<script>
const ClientState = Object.freeze({
    disconnected: 0,
    connecting: 1,
    connected: 2,
    error: 3,
});
const GameState = Object.freeze({
    lobby: 0,
    shooting: 1,
    miss: 2,
    gameOver: 3
});
export default {
    name: "App",
    data() {
        return {
            connection: null,
            ipData: "",
            fireData: "",
            charStyle: undefined,
            error: "",
            clientState: ClientState.disconnected,
            gameState: GameState.lobby,
            ClientState,
            GameState,
            methodMap: {
                "hit": (data) => this.onHit(data),
                "miss": (data) => this.onMiss(data),
                "connected": (data) => this.onConnect(data),
                "gameOver": (data) => this.onGameOver(data),
            },
            name: "Someone",
            history: [],
        };
    },
    created() {
        // this.connect();
    },
    methods: {
        connect() {
            console.log("Starting connection to WebSocket Server");
            this.clientState = ClientState.connecting;
            this.error = "";
            if (this.ipData === "") {
                this.ipData = "127.0.0.1:9080";
            }
            this.connection = new WebSocket("ws://" + this.ipData);

            this.connection.onmessage = async (e) => {
                const encoded = await new Response(e.data).text();
                const pkt = JSON.parse(encoded);

                console.log("Received", pkt.method, pkt.data);

                if (this.methodMap[pkt.method] !== undefined) {
                    this.methodMap[pkt.method](pkt.data)
                }
            }
            this.connection.onopen = (e) => {
                console.log(e);
                console.log("Successfully connected to the server!");
                this.clientState = ClientState.connected;
            }
            this.connection.onerror = (e) => {
                console.log("Error", e);
                this.error = `Couldn't etablish a connection to host: ${this.ipData}.`;
                this.clientState = ClientState.disconnected;
            }
            this.connection.onclose = (e) => {
                console.log("Connection closed", e);
                this.connection = null;
                this.clientState = ClientState.disconnected;
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
        onConnect({ name, color, wait }) {
            this.name = name;
            this.charStyle = {
                'background-color': "#" + color
            };
            this.history = [];
            if (wait > 0) {
                this.gameState = GameState.lobby;
                setTimeout(() => {
                    this.gameState = GameState.shooting;
                }, wait);
            } else {
                this.gameState = GameState.shooting;
            }
        },
        onHit(data) {
            data['id'] = this.history.length
            this.history.push(data);
        },
        onMiss() {
            this.gameState = GameState.miss;
            this.fireData = "Missed!";
            setTimeout(() => {
                this.gameState = GameState.shooting;
                this.fireData = "";
            }, 1500);
        },
        onGameOver() {
            this.gameState = GameState.gameOver;
            setTimeout(() => {
                this.gameState = GameState.lobby;
                this.clientState = ClientState.disconnected;
                this.connection.close();
                this.connection = null;

            }, 30 * 1000)
        }
    }
};
</script>
<style>
body {
    @apply text-white bg-black;
    background-image: url("./images/stars_bg.png");
    background-repeat: repeat;
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