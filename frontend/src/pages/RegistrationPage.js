import React, {useContext, useState} from "react";
import { AnimatedPage } from "./AnimatedPage";
import { UserContext } from "../context/UserContext";
import { NavLink, useNavigate } from "react-router-dom";
import axios from 'axios';

export const RegistrationPage = ()=>{
    const rnavigate = useNavigate()
    const[firstname,setfirstname] = useState("")
    const[lastname,setlastname] = useState("")
    const[email,setemail] = useState("")
    const[password,setpassword] = useState("")
    const[sex,setsex] = useState("")
    const[phonenumber,setphonenumber] = useState(0)
    const[address,setaddress] = useState("")
    const[parentname,setparentname] = useState("")
    const[date_of_birth,setdate_of_birth] = useState("")
    const[date_joined,setdate_joined] = useState("")
    const [, settoken] = useContext(UserContext)

    const submitResponse = async()=>{
        const requestOptions = {
                "firstname": firstname,
                "lastname": lastname,
                "email": email,
                "hashpassword": password,
                "sex": sex,
                "address": address,
                "phone": phonenumber,
                "parentname": parentname,
                "date_of_birth": date_of_birth,
                "date_joined": date_joined
        }
        try{
        const url = `${process.env.REACT_APP_STUDENT_URL}/create`
        const response = await axios.post(url, requestOptions)        
        settoken(response.data.access_token)
        rnavigate("/studentsignin")
        }catch(err){
            console.log(err.response.data.detail)
        }
    }
    
    const handleSubmit = (e)=>{
        e.preventDefault()
        if(password>5){
            submitResponse();
        }
    }
    
    return(
        <AnimatedPage>
        <>

            <section className="sec1">
                
                <main>
                    <div className="container">
                        <div className="row">

                            <div className="col-2">
                                <div className="contacticons">
                                    <div className="mail">
                                        <img className="" style={{width:"43px"}} src="assets/images/icons8-gmail-logo-64.png" alt="" />
                                    </div>
                                    <div className="skype">
                                        <img style={{width:"43px"}} src="assets/images/icons8-skype-2019-64.png" alt="" />
                                    </div>
                                    <div className="discord">
                                        <img style={{width:"43px"}} src="assets/images/icons8-discord-64.png" alt="" />
                                    </div>
                                </div>
                            </div>

                            <div className="mainimg2div col-6">
                                <div className="mainimg2">
                                    <img className="mx-auto regimg1" src="assets/images/cr1wobg.png" alt="chacter" />
                                </div>
                            </div>

                            <div className="col-4">
                                <div className="loginform my-5" style={{width:"300px"}}>
                                    <form  id="lgform"  onSubmit={handleSubmit}  className="mt-4" action="" method="">
                                        <div className='row'>
                                            <div className='col-6'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="text" value={firstname} onChange={(e)=>setfirstname(e.target.value)} className="em fn form-control" id="firstname" placeholder="First Name" />
                                                    <label htmlFor="firstname">First Name</label>
                                                </div>
                                            </div>
                                            <div className='col-6'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="text" value={lastname} onChange={(e)=>setlastname(e.target.value)} className="em ln form-control" id="lastname" placeholder="Last Name" />
                                                    <label htmlFor="lastname">Last Name</label>
                                                </div>
                                            </div>
                                        </div>
                                        <div className="form-floating mb-2 email">
                                            <input style={{height:"50px"}} type="email" value={email} onChange={(e)=>setemail(e.target.value)} className="em form-control" id="floatingInput" placeholder="name@example.com" />
                                            <label htmlFor="floatingInput">Email address</label>
                                        </div>
                                        <div className="form-floating">
                                            <input style={{height:"50px"}} value={password} type="password" onChange={(e)=>setpassword(e.target.value)} className="em password form-control" id="floatingPassword" placeholder="Password" />
                                            <label htmlFor="floatingPassword">Password</label>
                                        </div>

                                        <div className='row mt-2'>
                                        <div className='col-6'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="text" value={parentname} onChange={(e)=>setparentname(e.target.value)} className="em fn form-control" id="uparentname" placeholder="parentname" />
                                                    <label htmlFor="uparentname">Parent Name</label>
                                                </div>
                                            </div>
                                            <div className='col-6'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="number" value={phonenumber} onChange={(e)=>setphonenumber(parseInt(e.target.value))} className="em ln form-control" id="uphonenumber" placeholder="phonenumber" />
                                                    <label htmlFor="uphonenumber">Ph Number</label>
                                                </div>
                                            </div>
                                        </div>

                                        <div className='row'>
                                            <div className='col-4'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="text" value={sex} onChange={(e)=>setsex(e.target.value)} className="em fn form-control" id="sex" placeholder="sex" />
                                                    <label htmlFor="sex">Sex</label>
                                                </div>
                                            </div>
                                            <div className='col-4'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="text" value={address} onChange={(e)=>setaddress(e.target.value)} className="em ln form-control" id="address" placeholder="address" />
                                                    <label htmlFor="address">City</label>
                                                </div>
                                            </div>
                                            <div className='col-4'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="date" value={date_of_birth} onChange={(e)=>setdate_of_birth(e.target.value)} className="em ln form-control" id="udate_of_birth" placeholder="date_of_birth" />
                                                    <label htmlFor="udate_of_birth">date_of_birth</label>
                                                </div>
                                            </div>
                                            <div className='col-4'>
                                                <div className="form-floating mb-2 email">
                                                    <input style={{height:"50px"}} type="date" value={date_of_birth} onChange={(e)=>setdate_joined(e.target.value)} className="em ln form-control" id="udate_joined" placeholder="date_joined" />
                                                    <label htmlFor="udate_joined">date_joined</label>
                                                </div>
                                            </div>
                                        </div>
                                    
                                        <div className="line3 my-3">
                                            <button type="submit" className="sgbtn btn btn-primary w-100 shadow">Register</button>
                                        </div>
                                        <div>
                                            <div className="recpass text-primary" id="loginbtn"><span className="text-dark me-2">already have an account?</span><NavLink style={{textDecoration:"none",fontFamily:"poppins",fontWeight:"700"}} className="text-primary" to="/studentsign">Log In</NavLink></div>
                                        </div>
                                    </form>
                                </div>

                            </div>
                        </div>
                    </div>
                </main>
            </section>

        </>
        </AnimatedPage>
    )
}