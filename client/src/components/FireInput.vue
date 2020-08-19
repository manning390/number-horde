<template>
    <div class="text-center">
        <input v-bind="inputData" class="rounded-l w-3/5 center my-6 mx-auto p-2 text-center text-black center" type="text">
        <button type="bg-red-500 hover:bg-red-700 rounded-r">Fire!</button>
    </div>
</template>
<script>
export default {
    name: 'FireInput',
    data() {
        inputData: ""
    },
    methods: {
        onFire(event) {
            this.$emit('submit', this.inputdata);
        }
    }
};
</script>
<style scoped>
</style>