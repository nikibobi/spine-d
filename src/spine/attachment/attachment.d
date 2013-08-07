module spine.attachment.attachment;

export abstract class Attachment {

    this(string name) {
        mixin(ArgNull!name);
        this.name = name;
    }

    @property {
        string name() {
            return _name;
        }
        private void name(string value) {
            _name = value;
        }
    }

    override string toString() {
        return name;
    }

private:
    string _name;
}