var express = require("express");
var router = express.Router();
require("dotenv").config();
const axios = require("axios");
const background = process.env.BACKGROUND_COLOR;
const DAPR_HOST = process.env.DAPR_HOST || "http://localhost";
const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT || "3500";

const api = axios.create({
  baseURL: `${DAPR_HOST}:${DAPR_HTTP_PORT}`,
  params: {},
  timeout: process.env.TIMEOUT || 15000,
  headers: {
    "dapr-app-id": "albumapi",
  }
});

// const api = axios.create({
//   baseURL: process.env.API_BASE_URL,
//   params: {},
//   timeout: process.env.TIMEOUT || 15000,
// });

/* GET home page. */
router.get("/", async function (req, res, next) {
  try {
    console.log("Sending request to backend albums api");
    var data = await api.get("/albums");
    console.log("Response from backend albums api: ", data.data);
    res.render("index", {
      albums: data.data,
      background_color: background,
    });
  } catch (err) {
    console.log("Error: ", err);
    next(err);
  }
});

module.exports = router;
