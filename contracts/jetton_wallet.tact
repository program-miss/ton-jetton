import "@stdlib/deploy";
import "./messages";

// кол-во типов криптовалюты у человека = кол-во контрактов кошельков,
// привязанных к этому человеку
contract JettonWallet with Deployable {
    parent: Address;
    owner: Address;
    balance: Int as coins;
    init(parent: Address, owner: Address){
        self.parent = parent;
        self.owner = owner;
        self.balance = 0;
    }

    // шаг 2
    receive(msg: InternalAdd){
        if (msg.origin == self.parent) {
            require(sender() == self.parent, "Parent only");
        } else {
            let init: StateInit = initOf JettonWallet(self.parent, msg.origin);
            require(sender() == contractAddress(init), "JettonWallet only");
        }
        self.balance = (self.balance + msg.amount);
    }

    // шаг 1
    receive(msg: Transfer){
        // проверяем, что sender является владельцем этого кошелька
        require(sender() == self.owner, "Access denied");
        // проверяем, что хватает баланса для отправки этих монет
        require(self.balance >= msg.amount, "Insufficient balance");
        // вычитаем у себя баланс
        self.balance = (self.balance - msg.amount);
        let init: StateInit = initOf JettonWallet(self.parent, msg.to);
        // формируем сообщение InternalAdd и отправляем тому, у кого должен увеличиться баланс
        send(SendParameters{
                to: contractAddress(init),
                body: InternalAdd{amount: msg.amount, origin: self.owner}.toCell(),
                value: ton("0.03"),
                mode: SendIgnoreErrors,
                code: init.code,
                data: init.data
            }
        );
        self.reply("transferred".asComment());
    }
}
