class PMNG_Execute {
    static createShareIn() {
        ; pending
    }

    static startModify(inhRooms, groupGuests) {
        curGuest := signal({})

        for guest in groupGuests {
            curGuest.set(guest)
            resvQty := inhRooms.map(room => room = curGuest.value["roomNum"]).Length
            guestQty := groupGuests.map(guest => guest["roomNum"] = curGuest.value["roomNum"]).Length

            if (guestQty > resvQty) {
                this.createShareIn()
            }

            ; search by guest 
            loop guestQty {
                ; search by dummy name snippet, if exist, mod it 
                ; else, search by 1, mod it
                ; if both not found , move to the next guest
            }

        }
    }
}