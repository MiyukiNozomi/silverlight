module silver.light.list;

//not that good btw, just a basic dynamic array with fancy classes.

import std.algorithm.mutation;

/** base to make a list*/
template List(T) {
    interface List {
        public:
            void add(T object);

            T get(int index);

            bool contains(int index);
            
            void remove(int index);
            
            ulong size();
    }
}

/**(simple) implementation of this thing*/
template ArrayList(T) {
    class ArrayList : List!T {
        private:
            T[] buffer;

        public:
			this() {}

            void add(T object) {
                buffer ~= object;
            }

            bool contains(int index) {
                return (index < this.size());
            }
            
            void remove(int index) {
                buffer.remove(index);
            }

            T get(int index) {
                return buffer[index];
            }

            ulong size() {
                return buffer.length;
            }
    }
}