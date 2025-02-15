PostDetails(post) {
    PD := Gui(, "Post Details")
    PD.SetFont(, "微软雅黑")
    PD.OnEvent("Close", (*) => PD.Destroy())
    
    content := signal(post["content"])

    columnDetails := {
        keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [60, 90, 40, 80, 145, 120]
    }

    options := {
        lvOptions: "vguestProfileList Grid -ReadOnly -Multi LV0x4000 w550 r8 y+10",
        itemOptions: ""
    }

    handleRepost() {
        newPost := agent.delegate(post["content"])
        newPost["status"] := "已发送"
        postQueue.set(cur => cur.unshift(newPost))
        PD.Destroy()
    }

    return (
        PD.AddGroupBox("Section r10", "代行详情"),
        PD.AddText("xs20 yp+20", "发送状态: " . post["status"]),
        PD.AddText("xs20 yp+20" , "客人资料"),
        PD.ARListView(options, columnDetails, content),
        PD.AddButton("w120 h30", "重新发送代行")
          .OnEvent("Click", (*) => (post["status"] := "已发送", agent.delegate(post["content"])))
    )
}