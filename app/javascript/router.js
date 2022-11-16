import {createWebHistory, createRouter} from "vue-router";
import HomePage from "@/pages/HomePage";

const routes = [
    {
        path: "/",
        name: "Home",
        component: HomePage,
        title: 'Shopping - Home Page'
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;