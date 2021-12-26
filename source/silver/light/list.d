module silver.light.list;

//not that good btw, just a basic dynamic array with fancy classes.

import std.algorithm.mutation;

/**a list*/
template List(T) {
    class List {
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

            void clear() {
                buffer = null;
            }

            static List!T empty() {
                return new List!T(); 
            }

            static List!T yield(T[] elms) {
                List!T theList = new List!T();

                foreach (elm ; elms) {
                    theList.add(elm);
                }

                return theList;
            }
    }
}