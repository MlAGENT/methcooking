window.addEventListener("message", (event) => {
    const data = event.data;
    if (data.action === "update_methlab") {
        const temp = data.temp;
        const pressure = data.pressure;

        document.getElementById("tempBar").style.width = `${temp}%`;
        document.getElementById("pressureBar").style.width = `${pressure}%`;

        document.getElementById("tempValue").innerText = `${temp}°C`;
        document.getElementById("pressureValue").innerText = `${pressure}%`;

        // Changer couleur si critique
        document.getElementById("tempBar").style.background = temp >= 90 ? 'red' : 'limegreen';
        document.getElementById("pressureBar").style.background = pressure >= 75 ? 'red' : 'limegreen';
    }

    if (data.action === "show_hud") {
        document.getElementById("hud").style.display = "flex";
    }

    if (data.action === "hide_hud") {
        document.getElementById("hud").style.display = "none";
    }
});
