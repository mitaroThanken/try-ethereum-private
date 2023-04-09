function OnSignerStartup(info) { }

function ApproveListing() {
  return "Approve";
}

function ApproveSignData(r) {
  if (r.content_type == "application/x-clique-header") {
    for (var i = 0; i < r.messages.length; i++) {
      var msg = r.messages[i];
      if (msg.name == "Clique header" && msg.type == "clique") {
        return "Approve";
      }
    }
  }
  return "Reject";
}

// 既知のアカウント
var accounts = [
  "0x108E30910a05EB43Da87a30575Afa53EC983a54d",
  "0xA206b499ddA19DC1D3b2cb4901a650aACF66b048",
  "0x25685A527709D66F5EbE024D5Fb5fc0f69a2b877"
];

// 既知のノード
var nodes = [
  "172.29.0.1",
  "172.29.0.2",
  "172.29.0.3"
];

function ApproveTx(r) {
  // 既知のノード・既知のアカウントからのリクエストであることを検証する

  // この要求が HTTP でリクエストされたものである
  if (r.meta.scheme === "http" && (r.meta.remote === undefined || r.meta.remote === null)) {
    console.log("ApproveTx: Reject: not http");
    console.log(JSON.stringify(r))
    return "Reject";
  }

  // ポート番号に用はない
  var remoteAddrAndPort = r.meta.remote.split(":");

  // が、IPアドレスとポート番号の組であることは確認しておく
  if (remoteAddrAndPort.length !== 2) {
    console.log("ApproveTx: Reject: not expected address");
    console.log(JSON.stringify(r))
    return "Reject";
  }

  // トランザクションのリクエスト元が既知のアカウントである
  var result = false;
  for (var i = 0; i < accounts.length; i++) {
    if (r.transaction.from.toLowerCase() === accounts[i].toLowerCase()) {
      result = true;
      break;
    }
  }
  if (!result) {
    console.log("ApproveTx: Reject: not expected from");
    console.log(JSON.stringify(r))
    return "Reject";
  }

  // トランザクションのリクエスト元が既知のノードである
  result = false;
  for (var i = 0; i < nodes.length; i++) {
    if (remoteAddrAndPort[0] === nodes[i]) {
      result = true;
      break;
    }
  }
  if (!result) {
    console.log("ApproveTx: Reject: not expected remote");
    console.log(JSON.stringify(r))
    return "Reject";
  }

  // トランザクションを受け入れる
  return "Approve";
}
