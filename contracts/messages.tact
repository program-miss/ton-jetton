message NewTodo {
    task: String;
}
message InternalSetTask {
    task: String;
}
message CompleteTodo {
    seqno: Int as uint256;
}
message InternalComplete {
    excess: Address;
}
message NewTodoResponse {
    seqno: Int as uint256;
}
