const express = require('express')
const app = express()
app.get('/api/groups/:groupId/next_event', (req, res) => {
    if (req.params['groupId'] != 'valid_id') res.status(400).send(Error('Invalid id'))
    res.send({
        "id": "1",
        "groupName": "Pelada Chega+",
        "date": "2024-01-11T11:10:00.000Z",
        "players": [{
            "id": "1",
            "name": "Cristiano Ronaldo",
            "position": "forward",
            "isConfirmed": true,
            "confirmationDate": "2024-01-10T11:07:00.000Z",
            "photo": "https://www.ogol.com.br/img/jogadores/new/15/79/1579_cristiano_ronaldo_20241125221757.png"
        }, {
            "id": "2",
            "name": "Lionel Messi",
            "position": "midfielder",
            "isConfirmed": true,
            "confirmationDate": "2024-01-10T11:08:00.000Z",
            "photo": "https://a.espncdn.com/combiner/i?img=/i/headshots/soccer/players/full/45843.png&w=350&h=254"

        }, {
            "id": "3",
            "name": "Dida",
            "position": "goalkeeper",
            "isConfirmed": true,
            "confirmationDate": "2024-01-10T09:10:00.000Z",
            "photo": "https://i.pinimg.com/474x/6a/85/d1/6a85d1c3d3e343a7dea94cabb0331bff.jpg"
        }, {
            "id": "4",
            "name": "Romario",
            "position": "forward",
            "isConfirmed": true,
            "confirmationDate": "2024-01-10T11:10:00.000Z",
            "photo": "https://lendasdofutebol.com/wp-content/uploads/2022/02/romario_copa-1994-optimized.jpg"
        }, {
            "id": "5",
            "name": "Claudio Gamarra",
            "position": "defender",
            "isConfirmed": false,
            "confirmationDate": "2024-01-10T13:10:00.000Z"
        }, {
            "id": "6",
            "name": "Diego Forlan",
            "position": "defender",
            "isConfirmed": false,
            "confirmationDate": "2024-01-10T14:10:00.000Z",
            "photo": "https://static.wikia.nocookie.net/futebolistas/images/c/c6/Forl%C3%A1n.png/revision/latest?cb=20101122073236&path-prefix=pt-br"
        }, {
            "id": "7",
            "name": "Zé Ninguém",
            "isConfirmed": false
        }, {
            "id": "8",
            "name": "Rodrigo Manguinho",
            "isConfirmed": false
        }, {
            "id": "9",
            "name": "Claudio Taffarel",
            "position": "goalkeeper",
            "isConfirmed": true,
            "confirmationDate": "2024-01-10T09:15:00.000Z"
        }]
    })
})
app.listen(8080, () => console.log('Server running at http://localhost:8080'))