const hre = require("hardhat");
const fs = require("fs")
let format = require("./Untitled-1.json")

let abi = hre.ethers.utils.defaultAbiCoder;
for(let i = 0; i < format.length; i++) {
    let elem = format[i]

    if(elem?.topics.includes("0x57404065c4cd836656ea7db89edb5e96fa981d269b0ed0530bd4fa1b24d43c08") && elem?.data.startsWith("0x")) {
        let [type,payload] = abi.decode(["bytes","bytes"], elem["data"])
        let real_types = [
            "string",
            ...abi.decode(["string", "string"], type)[1].split(",")
        ]

        let [,, name, value] = abi.decode(real_types, payload).toString().split(",")
        console.log(i, " > ", name, value)
        format[i].data = {
            name,
            value
        }
    }
    else if(elem?.event === "Log") {
        if(elem.args["_type"].startsWith("0x")) {
            elem.args["_type"] = abi.decode(["string", "string"], elem.args["_type"])[1].split(",")
        }

        let name, value
        if(elem.args["payload"].startsWith("0x")) {
            [,, name, value] = abi.decode(["string", ...elem.args["_type"]], elem.args["payload"]).toString().split(",")
            elem.args["payload"] = {
                name, 
                value
            }
        }
        else {
            ({name, value}) = elem.args["payload"]
        }
        console.log(i, " > ", name, value)
        format[i] = elem
    }
}
// 0x346851375e3acEE9Aa2267f357602d0ad620aF54
fs.writeFileSync("./Untitled-1.json", JSON.stringify(format))