import { Canvas } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";


import Blob from "./Blob/Blob";

function App() {

     return (
        <Canvas camera={{ position: [ 1.3, 0, -1.3 ]}}>
            <Blob />
            <OrbitControls />
        </Canvas>
    );
}
export default App;
