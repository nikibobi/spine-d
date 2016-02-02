module spine.ikconstraint.data;

import spine.bone.data;
import spine.util.argnull;

export class IkConstraintData {

    this(string name) {
        mixin(ArgNull!name);
        this.name = name;
        this.bendDirection = 1;
        this.mix = 1f;
    }

    @property {
        string name() {
            return _name;
        }
        private void name(string value) {
            _name = value;
        }
    }

    @property {
        ref BoneData[] bones() {
            return _bones;
        }
        private void bones(BoneData[] value) {
            _bones = value;
        }
    }

    @property {
        BoneData target() {
            return _target;
        }
        void target(BoneData value) {
            _target = value;
        }
    }

    @property {
        int bendDirection() {
            return _bendDirection;
        }
        void bendDirection(int value) {
            _bendDirection = value;
        }
    }

    @property {
        float mix() {
            return _mix;
        }
        void mix(float value) {
            _mix = value;
        }
    }

    override string toString() {
        return name;
    }

private:
    string _name;
    BoneData[] _bones;
    BoneData _target;
    int _bendDirection;
    float _mix;
}