import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor Token {
    // Debug.print("Hello");

    let owner : Principal = Principal.fromText("kidqb-6oip3-vgcg6-yhhnn-i4qju-ryi6a-o6gb4-3wby7-pmjmh-yyvwz-cqe");
    let totalSupply : Nat = 1000000000;
    let symbol : Text = "DSAM";

    private stable var balanceEntries: [(Principal, Nat)] = [];
    
    // create ledger key type=principal, value type= Nat
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
    if(balances.size() < 1) {
    // Add owner to ledger first entry
        balances.put(owner, totalSupply);
    };

    

    // checkBalance Method
    public query func balanceOf(who : Principal) : async Nat {

        let balance : Nat = switch (balances.get(who)){
            case null 0;
            case (?result) result;
        };

        return balance;
    };

    public query func getSymbol() : async Text {
        return symbol;
    };

    public shared(msg) func payOut() : async Text {
        // Debug.print(debug_show(msg.caller));

        if(balances.get(msg.caller) == null){
            let amount = 10000;
            let result = await transfer(msg.caller, amount);
            return result;
        } else {
            return "Already Claimed";
        }

    };
    
    public shared(msg) func transfer(to : Principal, amount : Nat) : async Text {
        let fromBalance = await balanceOf(msg.caller);

        if(fromBalance > amount){
            let newFromBalance : Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance = toBalance + amount;
            balances.put(to, newToBalance);

            return "Success";
        } else {
            return "Insufficient Fund";
        }
        
    };
    system func preupgrade(){
        balanceEntries := Iter.toArray(balances.entries());
    };

    system func postupgrade(){
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        
    };

};