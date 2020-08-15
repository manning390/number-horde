<template>
    <div class="text-center border border-red-500">
        Welcome to Number Horde!<br />
        <p class="text">
            To join a server, punch in the IP and Port below!
        </p>
        <label class="block">
            <div>Server IP:</div>
            <input type="text" name="ip" placeholder="127.0.0.1:9000" class="rounded">
        </label>
    </div>
</template>
<script>
export default {
    name: 'ConnectInput'
};
</script>
<style scoped>
</style>